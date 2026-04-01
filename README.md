# go4-fashion — Claude Code Plugin

Plugin for [Claude Code](https://claude.ai/code) that connects to the **go4.fashion** platform — an AI-first operating system for premium fashion brands.

## What it does

- **Connects to your go4 MCP server** — automatic configuration, zero manual setup
- **Provides ready-made workflows** — import orders, invoice, track expenses, manage materials
- **Teaches Claude your domain** — fashion brand operations, product lifecycle, BOM, B2B orders
- **Integrates with RAG** — Claude searches your brand's knowledge base before every decision and proposes saving new rules

## Installation

```bash
# From GitHub
/plugin install github:michal/go4-plugin

# Or test locally
claude --plugin-dir ./go4-plugin
```

On first run, the plugin prompts for:
- **MCP server URL** — your brand's go4 MCP deployment (e.g., `https://your-brand.railway.app/mcp`)
- **API token** — stored securely in system keychain

## Skills

### Action workflows (`/go4-fashion:xxx`)

| Skill | Purpose |
|-------|---------|
| `import-order` | Import order from PDF/Excel/CSV/scan |
| `billing` | Full invoicing cycle: billing order → advance → VAT |
| `new-expense` | Register cost invoice (from file or manual) |
| `monthly-report` | Monthly business overview with stats |
| `sync-products` | Sync products to invoicing system |
| `ship` | UPS rate quotes and package tracking |
| `manage-bom` | View/edit Bill of Materials |
| `import-collection` | Import product collection from document |

### Background knowledge (auto-loaded by Claude)

| Skill | Purpose |
|-------|---------|
| `go4-domain` | Domain model, entities, relationships, business rules |
| `rag-protocol` | How to use the brand's knowledge base (search before act, capture new rules) |

## Agents

| Agent | Specialization |
|-------|---------------|
| `billing-agent` | Invoicing, billing orders, advances, currency conversion |
| `materials-agent` | Materials, suppliers, BOM, composition, pricing |
| `orders-agent` | Order lookups, imports, statistics, customer data |

## Architecture

```
Plugin (generic, same for all brands)
  ↓ connects to
MCP Server (per-brand deployment on Railway, with brand's credentials)
  ↓ reads/writes
Supabase (per-brand database with RAG knowledge base)
```

The plugin contains no brand-specific knowledge. Brand rules live in the RAG layer (`ai_knowledge_base`) and grow organically through usage.

## Development

```bash
# Test locally
claude --plugin-dir "/path/to/go4-plugin"

# Reload after changes (inside Claude Code session)
/reload-plugins
```
