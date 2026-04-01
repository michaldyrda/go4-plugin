---
name: rag-protocol
description: Protocol for using the brand's knowledge base (RAG). How to search for rules before decisions and capture new rules during work. Load whenever making decisions or encountering business logic.
user-invocable: false
---

# RAG Protocol — Brand Knowledge Base

The brand's institutional knowledge lives in `ai_knowledge_base`, not in this plugin. You MUST follow this protocol to use it effectively.

## Before Every Decision: SEARCH

Before any action that modifies data or involves business judgment, search for existing rules:

```
knowledge_search(query: "<what you're about to do>", scope: "<relevant scope>")
```

**Scopes:**
- `supplier_terms` — vendor pricing, MOQ, lead times, policies
- `customer_behavior` — client preferences, payment patterns, special terms
- `billing` — invoicing rules, payment terms, currency preferences
- `order_import` — size formats, SKU conventions, document parsing rules
- `material_procurement` — sourcing preferences, stock lot policies
- `brand_dna` — brand positioning, margin targets, quality standards
- `operational` — general process rules, seasonal patterns

**When to search:**
- Importing an order → search for customer rules AND order_import rules
- Creating an invoice → search for billing rules AND customer_behavior
- Adding a material → search for supplier_terms AND material_procurement
- Any decision where you're unsure → search with a broad query

**How to use results:**
- If rules exist: follow them. They represent decisions the manager already made.
- If rules conflict with the current request: tell the manager about the conflict and ask how to proceed.
- If no rules found: proceed with your best judgment, then propose capturing a rule (see below).

## After Discovering New Patterns: CAPTURE

When you encounter a new business rule, exception, or pattern — propose saving it:

> "I noticed [observation]. Should I save this as a rule for future reference?"

If the manager agrees, capture it:

```
knowledge_capture(
  scope: "<appropriate scope>",
  label: "<short descriptive label>",
  instruction: "<full rule text — specific, actionable, with context>"
)
```

**Good rule examples:**
- "Client Maison Bleue always requires proforma before production starts"
- "Size charts from Italian boutiques use EU numeric (38-48), not letter sizes"
- "Fabric from Textile World: always order 10% extra — their rolls run short"

**Bad rule examples:**
- "Client X placed an order" — this is a fact, not a rule
- "Materials are important" — too vague, not actionable

**Write rules that your future self can act on without asking the manager again.**

## The Learning Loop

```
Session 1: Manager says "For this client, always use EUR"
           → You capture: scope=customer_behavior, label="Client X — EUR only"

Session 2: Order comes in for Client X
           → You search knowledge_base → find the EUR rule → apply it automatically
           → Manager doesn't need to repeat themselves
```

This is how the brand's AI assistant gets smarter over time. Every captured rule is one less question the manager has to answer in the future.
