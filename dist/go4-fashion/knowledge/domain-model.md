# go4.fashion — Domain Model & Universal Rules

This is the data model and the universal rules of the go4.fashion platform. Read this once per session before working with any go4 entity.

## Core Entities

### Products & Collections
- **collection** → seasonal grouping (SS/AW + year). Has cutoff_date for B2B orders.
- **product** → a design (name, number, category). Lifecycle: designing → sampling → production → ready → archived.
- **product_variant** → specific SKU = product + color + size. Has its own price, stock, billing_product_id.
- **color** → organization-wide palette with hex, multilingual names (en/pl), production_tags.
- **size_group** → size hierarchy per org (XS-XL, 36-44, numeric).

### Orders & Customers
- **customer** → B2B client (boutique/retailer). Has tier, discount %, preferred currency, language.
- **sales_order** → order header. Status: pending → confirmed → in_production → shipped → completed / cancelled.
- **sales_order_item** → line item = product_variant + quantity + unit_price at order time.

### Materials & Supply Chain
- **material** → raw material. Types: fabric, button, zipper, thread, accessory, label, trim, packaging.
- **material_variant** → color/pattern variant of a material.
- **supplier** → material vendor with country, lead_time_days, payment_terms, material_categories.
- **supplier_material_terms** → **single source of truth for material costs**. Price tiers, MOQ, lead time per supplier+material.
- **product_bom** → Bill of Materials: links product+color to materials with consumption rate, waste_factor, placement (main/lining/trimmings).

### Production
- **production_plan** → per-collection demand aggregation.
- **production_order** → work order to manufacturer (sewing, printing, dyeing).
- **inventory_products** → finished goods stock per variant.
- **inventory_materials** → raw material stock (on-hand vs reserved).

### Knowledge & Events
- **ai_knowledge_base** → brand-specific business rules stored as embeddings. Scoped by domain (supplier_terms, customer_behavior, billing, etc.). This is the brand's institutional memory.
- **activity_events** → audit log of all system events with causality chain (triggered_by).

## Entity Relationships

### Product Hierarchy

```
collection (SS26, AW26)
  └── product (ISLA dress, NORA coat)
        ├── product_variant (ISLA-BLK-S, ISLA-BLK-M, ISLA-WHT-S...)
        │     ├── color ← from organization palette
        │     ├── size ← from size_group
        │     ├── billing_product_id ← synced to invoicing system
        │     └── inventory_products (stock per variant)
        │
        └── product_bom (per product+color)
              └── material + consumption + waste_factor + placement
```

### Order Flow

```
customer
  └── sales_order (pending)
        ├── sales_order_item (variant + qty + price)
        │
        ├── [confirm] → status: confirmed
        │     └── allocate: stock → allocated, remainder → production_needed
        │
        ├── billing_order_id ← created in invoicing system
        │     ├── advance_invoice (deposit, e.g. 30%)
        │     └── final_invoice (VAT)
        │
        └── [ship] → status: shipped
              └── UPS tracking_number
```

### Material Supply Chain

```
supplier
  └── supplier_material_terms ← SINGLE SOURCE OF TRUTH for costs
        ├── material + variant
        ├── price_tiers [{min_qty, price}]
        ├── MOQ, lead_time_days
        └── currency, valid_from/to

material
  ├── material_variant (color variants)
  ├── material_attribute_values (composition, GSM, width, stretch)
  └── product_bom → links to products
```

### Knowledge Layer

```
ai_knowledge_base
  ├── scope: supplier_terms    → "Vendor X: MOQ 100m, no samples"
  ├── scope: customer_behavior → "Client Y always pays in EUR"
  ├── scope: billing           → "Advances max 50% for new clients"
  ├── scope: order_import      → "Size format: EU numeric for IT clients"
  ├── scope: material_procurement → "Always check stock lots first"
  └── scope: brand_dna         → "Premium positioning, min margin 60%"
```

### Identifier Matching (Cascading)

Most tools accept multiple identifier types in order of precision:
1. UUID (exact)
2. Code/number (exact: color_code, product_number, SKU)
3. Name (fuzzy: partial match, case-insensitive)

Claude can reference data without knowing exact IDs — tools resolve names to IDs.

## Universal Business Rules

1. **Material costs come ONLY from `supplier_material_terms`**, never from `material_variants.cost_per_unit` (deprecated).
2. **Soft-delete everywhere**: `is_archived=true`, never hard-delete business data.
3. **SKU format**: `{PREFIX}-{NUMBER}-{COLORCODE}-{SIZE}` (e.g., `SHB-2161-BLK-M`).
4. **Order confirmation triggers allocation**: items allocated from stock, remainder flagged for production.
5. **Billing identifiers are provider-neutral**: `billing_client_id`, `billing_order_id`, `billing_product_id` — these map to whatever invoicing system the brand uses.

## Two-Stage Tool Pattern

Several tools use a parse→confirm pattern:
1. First call returns a **preview** with validations, warnings, and parsed data.
2. Manager reviews and approves.
3. Second call with confirmation flag or session_data executes the write.

Tools using this pattern: `import_order`, `create_billing_order`, `create_advance_invoice`, `assign_staging_media`, `import_collection`, `reorder_media`, `update_media_assignment`, `manage_product_categories`.

**Never skip the preview step.** Always show the manager what will happen before committing.
