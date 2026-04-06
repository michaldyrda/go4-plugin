---
name: go4-domain
description: go4.fashion domain model and entity relationships — products, orders, materials, BOM, collections, customers. Load when working with any go4 MCP tools to understand the data model.
user-invocable: false
---

# go4.fashion Domain Model

You are working with go4.fashion — an operating system for premium fashion brands. Understand this domain before taking any action.

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

For detailed entity relationships, see [domain-model.md](domain-model.md).

## Key Business Rules (Universal)

1. Material costs come ONLY from `supplier_material_terms`, never from `material_variants.cost_per_unit` (deprecated).
2. Soft-delete everywhere: `is_archived=true`, never hard-delete business data.
3. SKU format: `{PREFIX}-{NUMBER}-{COLORCODE}-{SIZE}` (e.g., `SHB-2161-BLK-M`).
4. Order confirmation triggers allocation: items allocated from stock, remainder flagged for production.
5. Billing identifiers are provider-neutral: `billing_client_id`, `billing_order_id`, `billing_product_id` — these map to whatever invoicing system the brand uses.

## Two-Stage Tool Pattern

Several tools use a parse→confirm pattern:
1. First call returns a **preview** with validations, warnings, and parsed data.
2. Manager reviews and approves.
3. Second call with confirmation flag or session_data executes the write.

Tools using this: `import_order`, `create_billing_order`, `create_advance_invoice`, `assign_staging_media`, `import_collection`, `reorder_media`, `update_media_assignment`, `manage_product_categories`.

**Never skip the preview step.** Always show the manager what will happen before committing.

## Media Tools

- `list_media` — list media assigned to a product/collection/material. Use `artifact: true` to get an HTML thumbnail gallery in chat.
- `assign_staging_media` — match files from Staging tab to products/collections/materials by filename.
- `reorder_media` — change sort order via ordered list of `assignment_id`s.
- `update_media_assignment` — change context (primary/gallery/swatch/…) or link to a specific color.

## Product Tools

- `manage_product_categories` — list, rename, move products between categories, delete empty categories.

## BOM & Labels

- `manage-bom` skill — view/edit BOM (materials, consumption, placement).
- `label-composition` skill — calculate EU textile composition label (EU Reg. 1007/2011) from BOM data. Returns label text per color variant with fiber percentages.

## Material Ordering

- `order-materials` skill — full flow from demand to Purchase Order.
  - Algorithm 1: fetch demand (v_material_order_demand), classify above/below MOQ, present costs, manager decides ordered_qty, save decisions, create PO per supplier.
  - Algorithm 2 (surplus): for below_moq materials — find candidate products, calculate bundle effect (domino), ROI_score per product (margin × rotation_factor / investment), interactive recalculation, return to Alg 1.
  - Tools needed: `get_material_demand`, `get_surplus_candidates`, `save_material_decisions`, `create_material_po`.
