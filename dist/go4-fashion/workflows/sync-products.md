# Workflow: Sync Products to Invoicing System

Ensure go4 products exist in the invoicing system's product dictionary so billing orders and invoices can reference them.

## What this does

Each product variant (color + size) = one entry in the invoicing system.
Format: `"{Product Name} — {Color}/{Size}"` (e.g., "ISLA — Black/S").

Variants that already have a `billing_product_id` are skipped (unless `force: true`).

## Step 1: Determine scope

From the manager's request, determine what to sync:
- A single product: `create_fakturownia_product(product_name: "...")`
- An entire collection: `create_fakturownia_product(collection_name: "...")`

If unclear, ask the manager.

## Step 2: Run sync

Call `create_fakturownia_product` with:
- `product_name` or `collection_name`
- `currency` (brand's default, usually EUR)
- `tax` (default: 0 for B2B export)

## Step 3: Report results

Show:
- Created: count and list
- Skipped (already synced): count
- Errors: details

If errors occurred (e.g., missing color mapping), help the manager resolve them.
