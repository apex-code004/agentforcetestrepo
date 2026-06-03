---
applyTo: "**/lwc/**"
---

# Amadeus Hospitality – LWC Coding Standards

## Component Structure
- One parent component makes Apex wire calls and passes data down via `@api`
- Child components NEVER call Apex directly — receive data from parent only
- Fire events UP to parent using `CustomEvent` — never call Apex from a child

## JavaScript Rules
- Use `@api` for properties passed from parent
- Use `@track` only when needed for deep object reactivity
- Use `@wire` for cacheable Apex calls — use `imperative` only for non-cacheable
- Always handle both `data` and `error` in wire handlers
- Use `refreshApex` after imperative DML calls to refresh wired data

## Error Handling
- Always show user-friendly error messages via `lightning-card` or toast
- Use `ShowToastEvent` for success/error feedback
- Never expose raw Apex error messages to the user

## Events
- Child → Parent: `CustomEvent` with `bubbles: true, composed: true`
- Cross-component: use Lightning Message Service (`lightning/messageService`)
- Never use `window` events or direct DOM manipulation

## HTML Templates
- Use `if:true` / `if:false` for conditional rendering
- Always provide `key` on `for:each` loops
- Use SLDS utility classes — never write custom CSS for layout
- Use `lightning-*` base components wherever possible

## Performance
- Never make multiple wire calls when one will do
- Use a single parent wire call and distribute data to children via `@api`
- Avoid `querySelector` — use template refs or event delegation
