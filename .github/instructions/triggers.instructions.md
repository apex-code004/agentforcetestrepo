
---
applyTo: "**/*Trigger*.cls,**/triggers/**/*.trigger"
---

# Amadeus Hospitality – Apex Trigger Rules

## Naming
- Trigger file name: `AH_<ObjectName>_<Event>` e.g. `AH_Task_AfterInsert`
- One trigger per object per event type (never combine `before insert, after insert` in one trigger)

## Structure
- Trigger body must ONLY instantiate the handler class and call its method
- No business logic, SOQL, or DML inside the trigger itself
- Always add summary debug lines at the end

## Required Template

```apex
/***********************************************************************************************
Name            : AH_<ObjectName>_<Event>
Author          : 
Created Date    : 
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Call the <Event> Methods in the AH_<ObjectName>_TriggerHandler Class
                :
************************************************************************************************/
trigger AH_<ObjectName>_<Event> on <ObjectName> (<event>)
{
    AH_<ObjectName>_TriggerHandler handler = new AH_<ObjectName>_TriggerHandler();
    handler.On<Event>(Trigger.new);

    system.debug('  AH_<ObjectName>_<Event> SUMMARY: ');
    system.debug('  Limits.getQueries() = ' + Limits.getQueries());
}
```

## Rules
- ✅ One event type per trigger file
- ✅ Handler instantiation + method call only
- ✅ Summary debug lines at end
- ❌ No SOQL inside triggers
- ❌ No DML inside triggers
- ❌ No business logic inside triggers
