# go4-plugin — Claude Code Plugin for go4.fashion

## What this is

A Claude Code plugin for the go4.fashion platform — an AI-first operating system for premium fashion brands. This plugin is the **manager interface** (Layer 4) and **agent foundation** (Layer 6) of the go4.fashion architecture.

## Architecture: Three-Layer Separation

**Plugin (this repo)** — generic, same for all brands. Contains:
- MCP server connection config (URL + token from userConfig)
- Domain knowledge skills (go4-domain, rag-protocol)
- Action workflow skills (import-order, billing, new-expense, etc.)
- Specialized agents (billing, materials, orders)

**MCP Server** (separate repo: `go4 mcp/`, deployed on Railway per brand) — contains:
- 37 tools (orders, invoicing, materials, BOM, colors, UPS, knowledge base)
- Brand-specific credentials (Fakturownia API, UPS, Supabase) in env vars
- Business logic and integrations

**RAG** (in Supabase `ai_knowledge_base` per brand) — contains:
- Brand-specific business rules (supplier terms, customer preferences, billing rules)
- Grows organically through usage via `knowledge_capture` tool
- Searched before every decision via `knowledge_search`

## Key Principle

**Nothing brand-specific in this plugin.** No "Fakturownia", no "Studio B3", no credentials. The plugin teaches Claude HOW to work with go4.fashion generically. Brand knowledge lives in RAG.

## Skills Design Rules

- Instructions in English (Claude processes English more precisely)
- Every action skill starts with `knowledge_search` (RAG-first protocol)
- Two-stage tools always show preview before commit
- `disable-model-invocation: true` for action workflows (user triggers them)
- `user-invocable: false` for background knowledge (Claude loads automatically)
- Supporting files (domain-model.md) for detailed reference material

## MCP Server Reference

The MCP server (go4 mcp) has 37 tools across these categories:
- System: test_connection
- Orders: list_orders, import_order (2-stage), get_order_stats
- Customers: get_customer
- Invoicing: list_invoices, get_invoice_details, get_invoice_pdf, create_invoice, copy_fakturownia_invoice, copy_invoice_with_product_prices, create_fakturownia_product, list_fakturownia_products
- Expenses: create_expense, add_expense_from_file, list_expenses, get_expense
- Billing: create_billing_order (2-stage), create_advance_invoice (2-stage)
- Materials: add_material, add_material_with_file, get_material, update_material
- Suppliers: add_supplier, update_supplier
- Colors: get_color, list_colors, set_color_production_tags, list_production_tags
- BOM: get_product_bom, set_bom_item
- Knowledge: knowledge_capture, knowledge_search
- Shipping: ups_rate_shipment, ups_track_shipment
- Media: assign_staging_media (2-stage)
- Collections: import_collection (2-stage, placeholder)

## Testing

```bash
claude --plugin-dir /path/to/go4-plugin
```

Reload after changes: `/reload-plugins` in Claude Code session.
