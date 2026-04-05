---
name: label-composition
description: Calculate EU textile composition label for a product — per color variant, per EU Regulation 1007/2011. Uses BOM data with fiber composition, GSM, and width.
disable-model-invocation: true
argument-hint: [product name or number]
---

# Label Composition

Generate EU-compliant textile composition labels for a product, based on its BOM.

**Regulation**: EU 1007/2011 (Textile Fibre Names and Labelling)

## Before you start

```
knowledge_search(query: "composition label <product name>", scope: "material_procurement")
knowledge_search(query: "textile label rules", scope: "material_procurement")
```

Apply any brand-specific rules found (e.g. "always treat elastic as trimming", "minimum weight for binding inclusion").

## Step 1: Fetch BOM

Call `get_product_bom` with `product_name` or `product_number` from `$ARGUMENTS`.

Each BOM line should have:
- `composition` (structured fibers: `[{ fiber: "cotton", percentage: 80 }, ...]`)
- `weight_gsm` (fabric weight g/m²)
- `width_total_cm` (fabric width in cm)
- `consumption` (meters per unit)
- `placement` (`main`, `lining`, `trimmings`)
- `binding_length_m`, `binding_width_mm` (for binding/tape materials)
- `material_type` (`fabric`, `button`, `zipper`, `thread`, `label`, `accessory`, `trim`, etc.)

## Step 2: Classify materials

For each BOM line, determine its **label role**:

| Material type | Label role |
|---|---|
| `fabric` | **textile component** — always included |
| `thread` | textile component — include if `weight_gsm` × area is available |
| `trim`, `label` | **trimming** — subject to 3% threshold |
| `button`, `zipper`, `accessory`, `packaging` | **non-textile** — excluded from label |

When `placement = "trimmings"` explicitly, treat as trimming regardless of material type.

## Step 3: Calculate mass per BOM line

For **fabric/thread** (area-based):

```
width_m = width_total_cm / 100
area_m2 = consumption [m] × width_m
mass_g = area_m2 × weight_gsm
```

For **binding/tape** (linear, if binding_length_m and binding_width_mm are set):

```
width_m = binding_width_mm / 1000
area_m2 = binding_length_m × width_m
mass_g = area_m2 × weight_gsm
```

If `weight_gsm` or `width_total_cm` is missing for a required material, **stop and ask the manager** to provide the missing data or confirm estimated values. Do not invent weights.

## Step 4: Apply trimming threshold

Sum mass of all textile components (mandatory).
For each trimming material:
- `trimming_share = trimming_mass / total_textile_mass`
- If `trimming_share < 0.03`: **exclude** from label; add note "exclusive of trimmings"
- If `trimming_share ≥ 0.03`: **include** in composition calculation

## Step 5: Aggregate fibers

For each included material (textile components + qualifying trimmings):

```
For each fiber in material.composition:
  fiber_mass_g = (fiber.percentage / 100) × material_mass_g
```

Sum fiber masses across all included materials.

Calculate final percentages:
```
fiber_pct = (fiber_total_mass / sum_all_fiber_masses) × 100
```

Round to nearest integer. Adjust largest component so all percentages sum to 100%.

Apply **3% fiber threshold**:
- Fibers with `fiber_pct < 3%`: group together as **"other fibres"**
- Exception: if brand rule requires naming them (e.g. "always show elastane"), keep them

## Step 6: Format label text

**Descending by percentage**. Format:

```
{percentage}% {Fiber Name}
```

Capitalize fiber names per EU standard (e.g. Cotton, Polyester, Elastane).

Use official EU fiber names (EU Reg. 1007/2011 Annex I):
- cotton, polyester, polyamide (not nylon), elastane (not lycra/spandex), viscose, wool, linen, acrylic, polypropylene, etc.

If trimmings were excluded: append `"exclusive of trimmings"` (or local language equivalent).

**Multi-component products** (e.g. jacket = shell + lining):
- If shell and lining have different compositions, label them separately:
  ```
  Shell: 70% Cotton, 30% Polyester
  Lining: 100% Polyester
  exclusive of trimmings
  ```
- Shell = `placement: "main"`, Lining = `placement: "lining"`

## Step 7: Present results

Show one label per **color variant** (if compositions differ per color) or a single label if all colors are identical.

Present as a table:

| Color | Label text |
|---|---|
| Black | 95% Cotton, 5% Elastane |
| Navy | 95% Cotton, 5% Elastane |

Then show calculation breakdown so the manager can verify:
- Materials included / excluded
- Mass per material
- Fiber totals before rounding

## Step 8: Handle edge cases

- **Missing composition data**: Report which materials lack `composition`. Ask manager to update via `update_material` or check with supplier.
- **"100% Organic Cotton"** or certified fibers: ask manager whether certification claim should appear on label (this is outside the composition algorithm).
- **Decorative elements** (patches, embroidery): if substantial, ask manager whether to include as trimming.

## After calculation

If new rules were applied or discovered (e.g. "for this product, elastic waistband is always treated as trimming"), propose capturing via:
```
knowledge_capture(content: "...", scope: "material_procurement", label: "label-composition rule: <product>")
```
