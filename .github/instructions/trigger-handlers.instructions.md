---
applyTo: "**/*_TriggerHandler.cls"
---

# Amadeus Hospitality – Trigger Handler Class Rules

## Naming
- File name: `AH_<ObjectName>_TriggerHandler.cls`
- Check for legacy `NI_<ObjectName>_TriggerHandler` before creating a new one

## Required Structure

### 1. Description Header (mandatory at top)
```apex
/***********************************************************************************************
Name            : AH_<ObjectName>_TriggerHandler
Author          : 
Created Date    : 
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Trigger Handler for <ObjectName> object
                :
************************************************************************************************/
```

### 2. Bypass Switch (mandatory in every handler)
```apex
public class AH_<ObjectName>_TriggerHandler
{
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}

    public AH_<ObjectName>_TriggerHandler()
    {
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }
```

### 3. Public Entry Methods (use exact signatures)
```apex
    public void OnBeforeInsert(List<OBJECTNAME__c> newTrigger)
    {
        if (!bpSwitch.Bypass<ObjectName>__c)
        {
            // calls to private methods only
        }
    }

    public void OnBeforeUpdate(List<OBJECTNAME__c> newTrigger)
    {
        if (!bpSwitch.Bypass<ObjectName>__c) {}
    }

    public void OnBeforeDelete(List<OBJECTNAME__c> newTrigger)
    {
        if (!bpSwitch.Bypass<ObjectName>__c) {}
    }

    public void OnAfterInsert(List<OBJECTNAME__c> newTrigger)
    {
        if (!bpSwitch.Bypass<ObjectName>__c) {}
    }

    public void OnAfterUpdate(List<OBJECTNAME__c> newTrigger, Map<Id, OBJECTNAME__c> mapOldTrigger)
    {
        if (!bpSwitch.Bypass<ObjectName>__c) {}
    }

    public void OnAfterDelete(List<OBJECTNAME__c> newTrigger)
    {
        if (!bpSwitch.Bypass<ObjectName>__c) {}
    }

    public void OnAfterUnDelete(List<OBJECTNAME__c> newTrigger)
    {
        if (!bpSwitch.Bypass<ObjectName>__c) {}
    }
```

### 4. Private Methods (business logic goes here)
```apex
    // ========================================
    // TRIGGER FUNCTIONS
    // ========================================
    private void createRecord(List<OBJECTNAME__c> newTrigger)
    {
    }

    private void deleteRecord(List<OBJECTNAME__c> newTrigger)
    {
    }
}
```

## Rules
- ✅ Always wrap logic in bypass switch check
- ✅ Public entry methods call private methods only — no logic directly in entry methods
- ✅ Use `// ===` style section headers, NOT `/**** */`
- ✅ Always use curly brackets even for single-line if statements
- ❌ NO public methods or functions — use a separate public static class instead
- ❌ NO ternary operators (`x = y != null ? y : 0` is forbidden)
- ❌ NO `else if` — use nested `else { if {} }` instead
- ❌ Remove development-only `system.debug` statements
