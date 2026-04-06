---
name: order-materials
description: Order materials for a collection or active demand — from requirement calculation to Purchase Order creation. Two-stage: core ordering + surplus decision support.
disable-model-invocation: true
argument-hint: [collection name or supplier name]
---

# Order Materials

Full flow from demand calculation to supplier Purchase Order.

## Before you start

```
knowledge_search(query: "material ordering rules", scope: "material_procurement")
knowledge_search(query: "<supplier name>", scope: "supplier_terms")
```

Apply any brand-specific rules found (MOQ overrides, preferred suppliers, buffer rules, etc.).

---

## Algorithm 1 — Core Ordering

### Step 1: Fetch demand

Call `get_material_demand` with filters from `$ARGUMENTS`:
- `collection` — optional
- `supplier` — optional
- `material` — optional
- Default: all confirmed + locked orders

Each row returns per (material_id, material_variant_id):
- `calculated_qty` — BOM × order qty × (1 + waste_factor)
- `stock_qty` — inventory on hand minus reserved
- `ordered_qty` — already in active POs (sent/confirmed/in_production/shipped/partially_received)
- `price_tiers` — [{min_meters, min_rolls, price_per_unit}]
- `moq_meters`, `moq_rolls`, `avg_roll_length_m`
- `currency`, `lead_time_days`, `supplier_id`, `supplier_name`
- `product_names`, `product_count`

### Step 2: Calculate per material

```
net_demand = MAX(0, calculated_qty - stock_qty - ordered_qty)

situation:
  "covered"    — net_demand = 0
  "above_moq"  — net_demand ≥ moq (or no MOQ)
  "below_moq"  — 0 < net_demand < moq

price_at_demand = lookup(price_tiers, qty=net_demand)  [highest matching tier]
price_at_moq    = lookup(price_tiers, qty=moq)         [only if below_moq]
cost_at_demand  = net_demand × price_at_demand
cost_at_moq     = moq × price_at_moq
delta           = moq - net_demand
suggested_qty   = MAX(net_demand, moq)

Fallback: if price_tiers empty → use unit_price
```

Skip `covered` materials by default (show only if manager asks).

### Step 3: Present to manager

Group by supplier. Show table per material:

| Field | Description |
|---|---|
| material + color | identifier |
| situation | covered / above_moq / below_moq |
| net_demand | what needs to be ordered |
| moq | minimum order quantity |
| delta | moq - net_demand (surplus if below MOQ) |
| cost_at_demand vs cost_at_moq | investment difference |
| lead_time_days | expected delivery |
| product_names | which products use this material |

Ask: **"Review quantities. Any changes? For below_moq items — order at MOQ or analyze surplus?"**

### Step 4: Manager decides per line

Manager can:
- Accept suggested_qty
- Override ordered_qty manually
- Skip a material (already ordered externally)
- Switch supplier (if alternatives exist in supplier_material_terms)
- For `below_moq` items → trigger **Algorithm 2** for surplus analysis

### Step 5: Save decisions

Call `save_material_decisions` per approved line:
```
material_id, material_variant_id,
ordered_qty, supplier_id,
unit_price (tier lookup for ordered_qty), currency
```

### Step 6: Create Purchase Orders

Group approved decisions by supplier → one PO per supplier.

Call `create_material_po`:
```
material_purchase_orders:
  supplier_id, status='draft', currency,
  collection_id (if filtered by collection),
  expected_delivery_date = today + lead_time_days,
  total_amount = SUM(ordered_qty × unit_price)

material_purchase_order_items:
  per line: material_id, material_variant_id, ordered_qty, unit_price, total_price
```

Show summary: PO numbers, suppliers, totals, expected delivery dates.

### Edge cases
- No supplier in view → flag material, ask manager to assign
- No MOQ → treat as above_moq, suggested_qty = net_demand
- No price_tiers → use unit_price, skip cost comparison
- Multiple suppliers → view returns preferred, offer alternatives if available

---

## Algorithm 2 — Surplus Decision Support

Triggered for `below_moq` materials when manager wants to evaluate what to do with surplus (delta = moq - net_demand).

### Economic context

Ordering at MOQ creates surplus material. Key question: **should we produce additional units now in a batch** (cheaper production) vs on-demand later (more expensive but no inventory risk)?

```
Investment   = delta × material_price + extra_units × sewing_cost
Alternative  = extra_units × on_demand_sewing_cost  [no inventory risk]
Risk         = extra_units × unit_price × P(unsold) + storage_cost × time
```

### Step 1: Find candidate products

Which products use this material in BOM? Per candidate:
```
max_qty = FLOOR(delta / consumption_of_this_material)
```

Call `get_surplus_candidates` with material_id + delta.

### Step 2: Check material bundle effect (domino)

For each candidate product and max_qty — check ALL other materials in its BOM:
```
needed_Y     = max_qty × consumption_Y
available_Y  = delta_Y (Y's own surplus) + free_Y (if above_moq, can add more)
to_buy_Y     = MAX(0, needed_Y - available_Y)
extra_cost_Y = to_buy_Y × price_Y
```

Total additional investment = Σ extra_cost_Y across all materials needed.

### Step 3: Calculate profitability per candidate

```
wholesale_price   = product_variants.unit_price
sewing_cost       = 15% × wholesale_price  [proxy — replace when production costs available]
material_cost     = Σ(consumption × unit_price) from BOM
gross_margin      = wholesale_price - material_cost - sewing_cost

rotation_factor   = category_score × color_score

  category_score:
    coat, jacket, blazer   → 1.0  (multi-season, stable demand)
    dress, skirt, trousers → 0.7  (seasonal)
    top, blouse, shirt     → 0.5  (highly seasonal)

  color_score:
    black, navy, white, grey → 1.0  (classic, low risk)
    muted (beige, ecru)      → 0.8
    bold, trendy colors      → 0.6  (higher sellout risk)

  [Both overridable by RAG rules — check knowledge_search first]

ROI_score = (gross_margin × rotation_factor) / total_additional_investment
```

### Step 4: Present ranking

Sorted by ROI_score descending. Per candidate show:
- max_qty producible from surplus
- materials needed to buy extra (and cost)
- gross_margin, total_investment, ROI_score
- rotation_factor source (category/color/RAG rule)
- recommended scenario: produce now / buy material only / skip

### Step 5: Interactive bundle recalculation

When manager selects a product + quantity:
- Show which materials are covered by surplus vs need extra purchase
- Recalculate total investment and ROI for the selection
- Show impact on other candidates (does this "steal" material from another option?)
- Update suggested ordered_qty for all affected materials

Ask: **"Which products to produce additional units for? Confirm quantities."**

### Step 6: Return to Algorithm 1

Approved surplus decisions update `ordered_qty` per material → return to Algorithm 1 Step 5 (save decisions + create POs).

### Rotation factor sources (priority order)
1. RAG rules — `knowledge_search(scope: "material_procurement")` — brand-specific overrides
2. Sales history per product [TODO — when available in DB]
3. Product category × color defaults (above)

### Known simplifications (to improve)
- `sewing_cost` = 15% wholesale price proxy → replace with production cost from DB when available
- No per-product sales history → using category/color as proxy
- No B2C sales plan integration → future: factor in planned B2C demand
- No material reservation per order → future: proper reservation system
- Drop and never-ending item rules → add via RAG knowledge rules

---

## Tools used

- `get_material_demand` — fetch v_material_order_demand with filters
- `get_surplus_candidates` — find products that can use surplus material
- `save_material_decisions` — write to material_order_decisions
- `create_material_po` — create material_purchase_orders + items
- `knowledge_search` — RAG rules for procurement and supplier terms
