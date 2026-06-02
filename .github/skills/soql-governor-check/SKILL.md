---
name: soql-governor-check
description: Checks Apex code for SOQL governor limit violations and query optimization issues
---
 
Scan the provided Apex code for SOQL governor limit violations using the following rules:
 
## Rules to Check
 
### 1. SOQL Inside Loops
- Detect any SOQL query (`[SELECT ...`] placed inside a `for`, `while`, or `do-while` loop
- Flag the exact line number and loop type
- Suggest moving the query outside the loop and using a Map/List to store results
 
### 2. Redundant SOQL Queries
- Detect multiple SOQL queries that fetch the same object type when one query with proper filtering would suffice
- Flag each redundant query with its line number
- Suggest combining into a single query using `WHERE Id IN :idSet` or similar
 
### 3. Missing Selective Filters
- Detect SOQL queries that run without indexed or selective WHERE clauses on large objects (Account, Contact, Lead, Opportunity, Case)
- Flag queries missing filters on indexed fields (Id, Name, Email, ExternalId__c)
- Suggest adding selective filters to avoid full table scans
 
### 4. Non-Bulkified Query Results
- Detect code that accesses query results with a hardcoded index (`results[0]`) without checking list size
- Flag every such occurrence
- Suggest using `if (!results.isEmpty())` before index access
 
## Output Format
 
For each violation found, report:
 
```
Line <N>: [SOQL-<RULE-CODE>] <short description>
→ Fix: <specific fix suggestion>
```
 
Rule codes:
- `SOQL-001` — SOQL inside loop
- `SOQL-002` — Redundant SOQL query
- `SOQL-003` — Non-selective filter
- `SOQL-004` — Unsafe index access on query result
 
If no violations are found, respond with:
```
✅ No SOQL governor limit violations detected.
```
 
 
