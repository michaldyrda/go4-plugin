# go4.fashion — Entity Relationships

## Product Hierarchy

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

## Order Flow

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

## Material Supply Chain

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

## Knowledge Layer

```
ai_knowledge_base
  ├── scope: supplier_terms    → "Vendor X: MOQ 100m, no samples"
  ├── scope: customer_behavior → "Client Y always pays in EUR"
  ├── scope: billing           → "Advances max 50% for new clients"
  ├── scope: order_import      → "Size format: EU numeric for IT clients"
  ├── scope: material_procurement → "Always check stock lots first"
  └── scope: brand_dna         → "Premium positioning, min margin 60%"
```

## Identifier Matching (Cascading)

Most tools accept multiple identifier types in order of precision:
1. UUID (exact)
2. Code/number (exact: color_code, product_number, SKU)
3. Name (fuzzy: partial match, case-insensitive)

Claude can reference data without knowing exact IDs — tools resolve names to IDs.
