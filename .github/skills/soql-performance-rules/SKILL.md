---
name: soql-performance-rules
description: Extends soql-governor-check with index analysis, query selectivity, batch thresholds, and SOQL performance optimization for large data volumes
---
 
Analyze the provided SOQL queries or Apex code for performance issues beyond governor limits — focusing on query selectivity, index usage, and large data volume (LDV) safety.
 
Apply this skill after or alongside `soql-governor-check` for a complete SOQL analysis.
 
## Rules to Check
 
### 1. Non-Selective WHERE Clauses on Large Objects
- For standard objects with potentially large data volumes (Account, Contact, Lead, Opportunity, Case, Task, Event, EmailMessage, ContentVersion), detect WHERE clauses that do not filter on an indexed field
- Standard indexed fields: `Id`, `Name`, `OwnerId`, `CreatedDate`, `LastModifiedDate`, `RecordTypeId`, `IsDeleted`, custom fields marked as External ID or Unique
- Flag non-selective queries on these objects
- Suggest adding a filter on an indexed field or requesting a Custom Index via Salesforce Support
 
### 2. SELECT * Pattern (All Fields)
- Detect `SELECT FIELDS(ALL)` or comments indicating intent to fetch all fields
- Flag — fetching unnecessary fields increases heap size and query time
- Suggest explicitly listing only required fields
 
### 3. Missing LIMIT on Open-Ended Queries
- Detect queries with no `LIMIT` clause on objects that could have unbounded record counts
- Flag — without LIMIT, queries can hit the 50,000 record governor limit
- Suggest adding `LIMIT` appropriate to the use case, or using Batch Apex for full-table processing
 
### 4. ORDER BY on Non-Indexed Fields
- Detect `ORDER BY` clauses on non-indexed fields
- Flag — sorting on non-indexed fields causes full table scans
- Suggest ordering on `CreatedDate`, `LastModifiedDate`, `Id`, or a Custom Indexed field
 
### 5. COUNT() Without WHERE
- Detect `SELECT COUNT() FROM [Object]` without a WHERE clause
- Flag — full table count queries are expensive on large objects
- Suggest adding a selective WHERE clause
 
### 6. Cartesian Query Risk (Cross-Object Without Filter)
- Detect child-to-parent or parent-to-child relationship queries where the join is not filtered
  e.g., `SELECT Id, (SELECT Id FROM Contacts) FROM Account` without a WHERE clause on Account
- Flag — unfiltered relationship queries can return massive result sets
- Suggest adding a WHERE clause on both sides of the relationship
 
### 7. Batch Apex Threshold Recommendation
- If a query is identified as likely to exceed 10,000 records based on context (no WHERE clause, large object, no LIMIT), recommend Batch Apex
- Suggest: "Use `Database.Batchable` with a query locator for processing more than 10,000 records safely"
 
### 8. Tooling API vs Data API Misuse
- Detect queries against metadata objects (ApexClass, ApexTrigger, CustomObject) in regular Apex
- Flag — metadata queries should use Tooling API, not standard SOQL in Apex (except in specific admin utilities)
 
## Performance Rating
 
After analysis, provide a query performance rating:
 
| Rating | Meaning |
|--------|---------|
| ✅ Green | Selective, indexed, bounded — safe for production |
| ⚠️ Yellow | Potentially slow at scale — review before deploying to LDV org |
| 🔴 Red | Will fail or timeout on production-size data — must fix |
 
## Output Format
 
```
Line <N>: [PERF-<CODE>] [Green/Yellow/Red] <description>
→ Fix: <optimization suggestion>
```
 
Rule codes:
- `PERF-001` — Non-selective WHERE clause on large object
- `PERF-002` — SELECT FIELDS(ALL) or all-field fetch
- `PERF-003` — Missing LIMIT on unbounded query
- `PERF-004` — ORDER BY on non-indexed field
- `PERF-005` — COUNT() without WHERE
- `PERF-006` — Unfiltered relationship query
- `PERF-007` — Query volume exceeds Batch Apex threshold
- `PERF-008` — Metadata object queried via standard SOQL
 
If no violations are found, respond with:
```
✅ All queries meet performance standards. Rating: Green
```
 
 
