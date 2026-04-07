# go4-plugin — Claude extension for go4.fashion

## What this is

A repository that ships go4.fashion intelligence to Claude in two parallel formats:

1. **Plugin** (`.claude-plugin/`, `skills/`, `agents/`) — the Claude Code plugin format. Used by Michał (developer) and any future customer on Team/Enterprise plan via private GitHub-backed marketplace. Auto-update friendly.
2. **Skill bundle** (`dist/go4-fashion/`) — a single uploadable Cowork skill packaged from the same source. Used by customers on Pro plan (e.g. Studio B3 today) who upload a ZIP via Customize → Skills. Manual updates.

Both formats are kept in sync. Same workflows, same RAG-first protocol, same domain knowledge — different delivery channels driven by what each customer's Anthropic plan supports.

This plugin is the **manager interface** (Layer 4) and **agent foundation** (Layer 6) of the go4.fashion architecture.

## Dual-track delivery (IMPORTANT)

| Customer situation | Format | Setup | Updates |
|---|---|---|---|
| Michał (Claude Code) | Plugin via `/plugin install` from this repo | `/plugin marketplace add michaldyrda/go4-plugin` | `git pull` / `/plugin update` |
| Customer on Team/Enterprise | Plugin via private GitHub marketplace | Org admin: Org Settings → Plugins → GitHub source → set Required + auto-sync | Auto on PR merge |
| **Customer on Pro (today: Studio B3)** | **Skill ZIP via Customize → Skills upload** | **Manager uploads `go4-fashion.zip` once + adds MCP connector** | **Manual: ZIP regenerated and re-uploaded by manager** |

**RULE: Every change to skill content must be reflected in BOTH `skills/` (plugin) AND `dist/go4-fashion/` (skill bundle) before commit.** Use the build script in `dist/build.sh` to regenerate the ZIP from `dist/go4-fashion/`.

The plugin format is the long-term target (auto-update wins). The skill bundle is the short-term workaround for Pro-tier customers. We do not abandon either — both ship from the same source until all customers are on Team or until the public Anthropic plugin directory accepts go4-fashion.

## Architecture: Three-Layer Separation

**Plugin / Skill bundle (this repo)** — generic, same for all brands. Contains:
- MCP server connection config (single multi-tenant URL, OAuth-based)
- Domain knowledge skills (go4-domain, rag-protocol)
- Action workflow skills (import-order, billing, new-expense, etc.)
- Specialized agents (billing, materials, orders) — plugin only, agents are not supported in skill bundle

**MCP Server** (separate repo: `go4 mcp/`, single multi-tenant deployment on Railway at `https://web-production-bdb8f.up.railway.app/mcp`) — contains:
- 37+ tools (orders, invoicing, materials, BOM, colors, UPS, knowledge base)
- Per-organization data isolation via OAuth
- Business logic and integrations (Fakturownia, UPS, Supabase)

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

**Plugin (Claude Code):**
```bash
claude --plugin-dir /path/to/go4-plugin
```
Reload after changes: `/reload-plugins` in Claude Code session.

**Skill bundle (Cowork on Pro):**
1. Run `dist/build.sh` to regenerate `dist/go4-fashion.zip`
2. In Claude Desktop → Customize → Skills → + → Upload `go4-fashion.zip`
3. Manager also adds MCP connector once: Settings → Connectors → Add custom → URL `https://web-production-bdb8f.up.railway.app/mcp` → OAuth login

## Workflow when editing skill content

1. Edit the source skill in `skills/<name>/SKILL.md`
2. Mirror the change in `dist/go4-fashion/workflows/<name>.md` (or `knowledge/` for go4-domain/rag-protocol)
3. Run `dist/build.sh` to rebuild the ZIP
4. Commit both changes together
5. For Pro customers (B3): send them the new ZIP, they re-upload
6. For Team/Enterprise customers: just push, marketplace auto-syncs
