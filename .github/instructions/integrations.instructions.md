---
applyTo: "**/INTGR_*.cls,**/integrations/**/*.cls"
---

# Amadeus Hospitality – Integration Class Rules

## Naming
- Integration components use `INTGR_` prefix, NOT `AH_`
- Pattern: `INTGR_<Acronym>_<Name>`
- Example: `INTGR_WinSN_Case_Handler`

## Required Description Header
```apex
/***********************************************************************************************
Name            : INTGR_<Acronym>_<Name>
Author          : 
Created Date    : 
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Integration handler for <integration name>
                :
************************************************************************************************/
```

## Error Logging (mandatory for ALL integrations)
- Use `DTS_Integration_Logger` class for ALL callout exceptions and integration errors
- Logs are written to `DTS_Integration_Log__c` custom object
- Never use generic `system.debug` alone for integration errors

```apex
try
{
    // integration callout logic
    HttpRequest req = new HttpRequest();
    HttpResponse res = new Http().send(req);
}
catch (Exception e)
{
    DTS_Integration_Logger.logError('INTGR_<Acronym>_<Name>', e.getMessage());
    system.debug('Integration error occurred : ' + e.getMessage());
}
```

## Rules
- ✅ Always use `INTGR_<Acronym>_` prefix (not `AH_`)
- ✅ Description header on every class
- ✅ All callout exceptions caught and logged via `DTS_Integration_Logger`
- ✅ Always use curly brackets, no ternary operators
- ✅ Section headers use `// ===` style only
- ❌ Never swallow exceptions silently
- ❌ No inline test data — use `NI_TestClassData`
