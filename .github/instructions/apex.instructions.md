---
applyTo: "**/*.cls"
---

# Amadeus Hospitality – Apex Coding Standards

## Naming Conventions
- Standard class: `AH_<Name>` — e.g. `AH_Functions`
- Trigger handler: `AH_<ObjectName>_TriggerHandler`
- Batch: `AH_<Name>_Batch` | Schedulable: `AH_<Name>_Schedule`
- Test class: `<ClassName>_Test`
- Integration: `INTGR_<Acronym>_<Name>` (NOT `AH_` prefix)
- All names must be approved before use

## Mandatory Description Header
Every class MUST start with:
```apex
/***********************************************************************************************
Name            : 
Author          : 
Created Date    : 
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : 
                :
************************************************************************************************/
```

## Sharing Declaration
- Every class MUST explicitly declare `with sharing` or `without sharing`
- Never omit the sharing declaration

## Coding Rules
- ❌ NEVER use ternary operators — use if/else with curly brackets
- ✅ ALWAYS use curly brackets on if/else, even single-line
- Use `// ===` style for section headers — never `/** */` block comments
- Remove unnecessary debug statements — always keep error-related debugs

## Error Handling
- Use `NI_Error_Logger` for ALL Apex errors
- Use `DTS_Integration_Logger` for ALL integration callout exceptions
- ❌ Never swallow exceptions (empty catch blocks are critical violations)
- ❌ Never log only `e.getMessage()` — always include stack trace

## SOQL Rules
- ❌ NEVER put SOQL inside a loop
- ❌ NEVER access query results without checking isEmpty() first
- Always use specific field names — never SELECT *
- Always add WHERE clause and LIMIT

## Bulkification
- All methods must safely handle 200+ records
- Use Map and Set for multi-record processing
- Never process only a single record when a list is passed
