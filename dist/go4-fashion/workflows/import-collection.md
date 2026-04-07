# Workflow: Import Collection

Import a product collection from an external document (Shopify export, Excel, CSV) into go4.fashion.

## Step 1: Identify the source

If the manager provided a file path, use it.
Otherwise, ask for the document (Shopify export, Excel, CSV, or manual data).

Determine `source_document_type`: `excel`, `pdf`, `csv`, or `manual`.

## Step 2: Collection metadata

Ask or extract:
- **Collection name** (e.g., "SS26")
- **Prefix** (for product numbers, e.g., "SS")
- **Season** and **year**
- **Currency** for pricing

## Step 3: Parse (stage 1)

Call `import_collection` with `action: "parse"`:
- `collection`: name, prefix, season, year
- `products[]`: name, number, description, colors (with sizes), pricing
- `currency`
- `source_document_type`

## Step 4: Review with manager

Show parsed products:
- Product name | Number | Colors | Sizes | Price
- Any warnings (missing data, duplicate numbers)

Ask: **"Zaimportować tę kolekcję? Coś poprawić?"**

## Step 5: Confirm (stage 2)

Call `import_collection` with `action: "confirm"` and `session_data` from stage 1.

Show: collection name, number of products created, link.
