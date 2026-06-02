---
applyTo: "**/*_Batch.cls,**/*_Schedule.cls"
---

# Amadeus Hospitality – Batch & Schedulable Class Rules

## Naming
- Batchable class:   `AH_<Name>_Batch.cls`      e.g. `AH_AccountCleanup_Batch`
- Schedulable class: `AH_<Name>_Schedule.cls`   e.g. `AH_AccountCleanup_Schedule`

## Required Description Header
```apex
/***********************************************************************************************
Name            : AH_<Name>_Batch / AH_<Name>_Schedule
Author          : 
Created Date    : 
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : 
                :
************************************************************************************************/
```

## Batchable Class Template
```apex
public class AH_<Name>_Batch implements Database.Batchable<sObject>
{
    // ========================================
    // START
    // ========================================
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id FROM <Object__c>]);
    }

    // ========================================
    // EXECUTE
    // ========================================
    public void execute(Database.BatchableContext bc, List<SObject> scope)
    {
        try
        {
            // business logic here
        }
        catch (Exception e)
        {
            NI_Error_Logger.logError('AH_<Name>_Batch', e.getMessage());
            system.debug('Error occurred : ' + e.getMessage());
        }
    }

    // ========================================
    // FINISH
    // ========================================
    public void finish(Database.BatchableContext bc)
    {
    }
}
```

## Schedulable Class Template
```apex
public class AH_<Name>_Schedule implements Schedulable
{
    // ========================================
    // EXECUTE
    // ========================================
    public void execute(SchedulableContext sc)
    {
        AH_<Name>_Batch b = new AH_<Name>_Batch();
        Database.executeBatch(b);
    }
}
```

## Error Handling (mandatory)
- Always wrap `execute()` logic in `try/catch`
- Log errors using `NI_Error_Logger` — never swallow exceptions silently

## Rules
- ✅ Description header on every class
- ✅ `try/catch` in all `execute()` methods
- ✅ Log exceptions via `NI_Error_Logger`
- ✅ Always use curly brackets, no ternary operators
- ❌ No inline test data in test classes — use `NI_TestClassData`
- ❌ No public methods that belong in trigger handlers
