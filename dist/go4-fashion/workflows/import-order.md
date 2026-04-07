# Workflow: Import Order

Import a sales order from an external document (PDF, Excel, CSV, or photo scan) into go4.fashion.

## Before you start

RAG rules are loaded automatically by `import_order` — the tool returns them in `rag_rules`. Read them before evaluating any issues.

Optionally also search for the customer:
```
knowledge_search(query: "<customer name>", scope: "customer_behavior")
```

## Step 1: Identify the source

If the user provided a file path, use it. Otherwise, ask for the document (PDF, Excel, CSV, or photo of a written order).

Determine `source_document_type`: `excel`, `pdf`, `image_scan`, or `csv`.

## Step 2: Parse (stage 1)

Read the document contents. Extract:
- **Customer**: name, and any identifiers (email, tax_id)
- **Items**: each line needs at least one identifier — `sku`, or `product_number` + `color` + `size`, or `product_name` + `color` + `size`
- **Currency**, **order_date**, **declared_total** (if present)
- **Collection**: name from document title, season (FW/SS + year), or product number prefix. Always pass as `collection_name` — the tool does fuzzy matching.
- **Status**: use `status: "completed"` for historical orders (past collections, already fulfilled). Default is `draft`.

Call `import_order` with `action: "parse"` and the extracted data.

## Step 3: Review with manager

Present the parsed result clearly:
- Customer (matched or new)
- Item table: product | color | size | qty | unit price
- Declared total vs calculated total
- Any warnings or issues (unknown SKUs, ambiguous matches)
- RAG rules that were applied

Ask: **"Zapisać to zamówienie? Coś poprawić?"**

## Step 4: Confirm (stage 2)

After approval, call `import_order` with `action: "confirm"` and `session_data` from stage 1.

Show confirmation: order number, status, link.

## If something new was learned

If you discovered a new pattern during import (e.g., this customer uses a specific size format, or their PO always includes a reference number), propose capturing it as a knowledge rule via `knowledge_capture`.
