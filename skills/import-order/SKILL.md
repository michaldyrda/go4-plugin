---
name: import-order
description: Import a sales order from a document (PDF, Excel, CSV, or photo scan) into go4.fashion. Two-stage process with preview and confirmation.
disable-model-invocation: true
argument-hint: [file path]
---

# Import Order

Import a sales order from an external document into go4.fashion.

## Before you start

1. **Search RAG** for import rules:
   - `knowledge_search(query: "order import rules", scope: "order_import")`
   - Also search for the customer if known: `knowledge_search(query: "<customer name>", scope: "customer_behavior")`
2. Apply any rules found (size format conventions, customer-specific pricing, etc.).

## Step 1: Identify the source

If the user provided a file path in `$ARGUMENTS`, use it.
Otherwise, ask for the document (PDF, Excel, CSV, or photo of a written order).

Determine `source_document_type`: `excel`, `pdf`, `image_scan`, or `csv`.

## Step 2: Parse (stage 1)

Read the document contents. Extract:
- **Customer**: name, and any identifiers (email, tax_id)
- **Items**: each line needs at least one identifier — `sku`, or `product_number` + `color` + `size`, or `product_name` + `color` + `size`
- **Currency**, **order_date**, **declared_total** (if present)

Call `import_order` with `action: "parse"` and the extracted data.

## Step 3: Review with manager

Present the parsed result clearly:
- Customer (matched or new)
- Item table: product | color | size | qty | unit price
- Declared total vs calculated total
- Any warnings or issues (unknown SKUs, ambiguous matches)
- RAG rules that were applied

Ask: **"Save this order? Anything to correct?"**

## Step 4: Confirm (stage 2)

After approval, call `import_order` with `action: "confirm"` and `session_data` from stage 1.

Show confirmation: order number, status, link.

## If something new was learned

If you discovered a new pattern during import (e.g., this customer uses a specific size format, or their PO always includes a reference number), propose capturing it as a knowledge rule.
