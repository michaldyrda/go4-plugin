---
name: manage-bom
description: View or edit the Bill of Materials (BOM) for a product — see which materials are used per color, update consumption rates, add or remove materials.
disable-model-invocation: true
argument-hint: [product name or number]
---

# Manage BOM

View and edit the Bill of Materials for a product.

## Before you start

Search for material rules:
- `knowledge_search(query: "BOM <product name>", scope: "material_procurement")`

## View BOM

Call `get_product_bom` with `product_name` or `product_number` from `$ARGUMENTS`.
Optionally filter by color.

Present the BOM grouped by color, showing:
- Material name | Placement (main/lining/trimmings) | Consumption | Waste factor | Notes

## Edit BOM

To add or update a BOM line, use `set_bom_item` with:
- Product identifier (name or number)
- Color identifier (name or code)
- Material identifier (name or ID)
- `consumption` (amount per unit)
- `waste_factor` (e.g., 0.15 = 15% waste)
- `placement`: main, lining, or trimmings
- Optional: `variant_parameter`, `notes`

To remove a BOM line: `set_bom_item` with `delete: true`.

## After changes

If consumption rates or waste factors were discussed and decided, propose capturing them as knowledge rules for future reference.

Show the updated BOM after each change so the manager can verify.
