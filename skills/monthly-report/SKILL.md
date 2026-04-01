---
name: monthly-report
description: Generate a monthly business report — order stats, revenue, expenses by category, top customers, top products. Aggregates data from orders and invoicing.
disable-model-invocation: true
argument-hint: [month, e.g. 2026-03]
---

# Monthly Report

Generate a monthly business overview.

## Step 1: Determine period

If `$ARGUMENTS` contains a month (e.g., `2026-03`), use it.
Otherwise, use the previous full calendar month.

Calculate `date_from` (first day) and `date_to` (last day).

## Step 2: Gather data (run in parallel)

Launch these queries concurrently:

1. `get_order_stats` with `date_from`, `date_to`, `group_by: "customer"` — top customers
2. `get_order_stats` with `date_from`, `date_to`, `group_by: "product"` — top products
3. `get_order_stats` with `date_from`, `date_to`, `group_by: "status"` — status breakdown
4. `list_invoices` with `date_from`, `date_to` — revenue invoices
5. `list_expenses` with `date_from`, `date_to` — cost invoices

## Step 3: Present the report

### Overview
- Total orders | Total units | Revenue | Average order value

### Revenue (invoices issued)
- By type (VAT, advance, proforma)
- By currency

### Costs (expenses)
- By category: materials, shipping, production, services, other
- Top 5 suppliers by amount

### Top 5 Customers
- Name | Orders | Revenue

### Top 5 Products
- Name | Units sold | Revenue

### Order Status Distribution
- Breakdown by status (confirmed, shipped, completed, etc.)

## Step 4: Insights

Add a brief "Takeaways" section:
- Notable changes vs expectations
- Unusually large or small cost items
- Customers with significant order changes

If the manager asks for comparison with a previous month, run the same queries for that period.
