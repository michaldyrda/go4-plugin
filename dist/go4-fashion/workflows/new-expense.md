# Workflow: New Expense

Register a cost invoice (expense) — material purchases, shipping, production services, or other costs. Supports document upload (PDF/photo) or manual entry.

## Before you start

If you know the supplier, search for existing terms:
```
knowledge_search(query: "<supplier name>", scope: "supplier_terms")
```

## Two paths

### Path A: From document (file provided)

Use `add_expense_from_file` — it reads the document, extracts data, uploads the file as attachment, and creates the expense.

Review the extracted data with the manager before confirming.

### Path B: Manual entry (no file)

Collect from the manager:
1. **Supplier** — who issued the invoice?
2. **Category**: `materials`, `shipping`, `production`, `services`, or `other`
3. **Line items**: name, quantity, unit price, VAT rate
4. **Currency** (default: brand's base currency)
5. **Dates**: issue date, payment deadline
6. **Supplier's invoice number** (for reference)

Call `create_expense` with the collected data.

## After creation

Show:
- Supplier name
- Total (net / gross)
- Category
- Link to the invoice in the invoicing system

## Notes

- Foreign currency expenses are automatically converted at the central bank rate
- If the expense relates to a specific material, include `material_id` to link them
- If you learn something new about this supplier (pricing, terms, quirks), propose saving it via `knowledge_capture`
