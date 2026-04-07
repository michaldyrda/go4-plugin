# Workflow: Billing

Complete invoicing cycle for a confirmed order. The sequence matters:
**billing order → advance invoice (optional) → final invoice**.

## Before you start

Search for billing rules:
- `knowledge_search(query: "billing rules", scope: "billing")`
- `knowledge_search(query: "<customer name>", scope: "customer_behavior")`

Apply any rules found (payment terms, currency preferences, advance requirements, etc.).

## Step 1: Find the order

Search by customer or order number. Call `list_orders` with the relevant filter.
Confirm with the manager which order to invoice.

## Step 2: Check product sync

The brand's invoicing system needs products in its dictionary. Check if all order variants have `billing_product_id`.

If products are missing, ask: **"Niektóre produkty nie są zsynchronizowane z systemem fakturowym. Zsynchronizować teraz?"**
If yes, use `create_fakturownia_product` with the product or collection name.

## Step 3: Billing order (two-stage)

Call `create_billing_order` with `confirmed: false` to preview.

Show: line items, amounts, customer, currency, language, any issues.

After manager approval, call with `confirmed: true`.

This saves `billing_order_id` on the order — required before any invoices.

## Step 4: Advance invoice (optional)

Ask: **"Wystawić zaliczkę? Jeśli tak, jaki procent lub kwota?"**

If yes, call `create_advance_invoice`:
- Preview first (`confirmed: false`)
- Show amount, remaining balance, payment terms
- Confirm (`confirmed: true`)

The system prevents advances from exceeding the order total.

## Step 5: Final invoice

Ask: **"Wystawić fakturę końcową?"**

If yes, use `copy_fakturownia_invoice`:
- `source_invoice_id`: the billing order ID
- `kind`: `"vat"` for final invoice
- Set payment terms from RAG rules or ask manager

For currency conversion (e.g., order in USD, invoice in EUR):
- Use `copy_invoice_with_product_prices` with `target_currency`

## Summary

Show the complete billing status:
- Billing order: ID, amount, link
- Advance (if created): amount, ID, link
- Final invoice (if created): amount, ID, link
- Remaining balance

## Rules to remember

- Billing order MUST exist before advance or final invoice
- Invoice language comes from customer's `b2b_panel_language`, overridable via `lang`
- If the customer doesn't exist in the invoicing system, `create_billing_order` creates them automatically
