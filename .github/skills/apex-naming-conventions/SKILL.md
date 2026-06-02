# Amadeus Hospitality – GitHub Copilot PR Review Instructions

You are reviewing Salesforce Apex code for Amadeus Hospitality.
For every Pull Request, validate ALL sections below and report violations clearly.
Do NOT approve code that fails any mandatory rule.

---

## 1. Naming Conventions

### Apex Classes

| Artifact               | Pattern                          | Example                              |
|------------------------|----------------------------------|--------------------------------------|
| Standard Class         | `AH_<Name>`                      | `AH_Functions`                       |
| Trigger                | `AH_<Object>_<Event>`            | `AH_Task_AfterInsert`                |
| Trigger Handler        | `AH_<ObjectName>_TriggerHandler` | `AH_Account_TriggerHandler`          |
| Batchable Class        | `AH_<Name>_Batch`                | `AH_Functions_Batch`                 |
| Schedulable Class      | `AH_<Name>_Schedule`             | `AH_Functions_Schedule`              |
| Queueable Class        | `AH_<Name>_Queueable`            | `AH_Functions_Queueable`             |
| Mock Class             | `AH_<Name>_Mock`                 | `AH_Functions_Mock`                  |
| Test Class             | `<ClassOrTriggerName>_Test`      | `AH_Account_TriggerHandler_Test`     |
| Controller Extension   | `<VFPageName>_Ext`               | `AH_SolutionSearch_Ext`              |
| Service Class          | `AH_<Object>_Service`            | `AH_Account_Service`                 |
| Selector Class         | `AH_<Object>_Selector`           | `AH_Account_Selector`                |
| Custom Exception       | `AH_<Domain>_Exception`          | `AH_Account_Exception`               |
| API Client             | `AH_<APIName>_ApiClient`         | `AH_Stripe_ApiClient`                |
| Request Wrapper        | `AH_<APIName>_Request`           | `AH_Stripe_Request`                  |
| Response Wrapper       | `AH_<APIName>_Response`          | `AH_Stripe_Response`                 |
| API Client Mock        | `AH_<APIName>_ApiClientMock`     | `AH_Stripe_ApiClientMock`            |

### Visualforce Pages & Components
- Must be prefixed with `AH_` — e.g. `AH_SolutionSearch`

### Integration Components
- Use `INTGR_<Acronym>_<Name>` prefix instead of `AH_`
- Example: `INTGR_WinSN_Case_Handler`

> ⚠️ IMPORTANT: All names MUST be approved before use. If not present in the project/SOW, flag in the PR review.

---

## 2. Method Naming Rules

- Use `camelCase` for all method names.
- **Boolean methods** must start with `is`, `has`, or `can` — e.g. `isEligible()`, `hasOpenCases()`
- **Trigger handler public entry methods** must use PascalCase matching the trigger event:
  - `OnBeforeInsert()`, `OnBeforeUpdate()`, `OnBeforeDelete()`
  - `OnAfterInsert()`, `OnAfterUpdate()`, `OnAfterDelete()`, `OnAfterUnDelete()`
- **Service methods** must use verb-noun form — e.g. `createTasks()`, `updateAccountStatus()`, `sendNotification()`
- **Selector methods** must start with `get` — e.g. `getById()`, `getByAccountId()`, `getOpenOpportunities()`

---

## 3. Variable Naming Rules

- Collections use plural nouns — `List<Account> accounts`, `Map<Id, Contact> contactMap`
- Loop variables use singular of the collection type — `for (Account acc : accounts)`
- ID sets suffix with `Ids` — `Set<Id> accountIds`
- Maps suffix with `Map` — `Map<Id, Account> accountMap`
- Constants in `UPPER_SNAKE_CASE` — `private static final Integer MAX_RECORDS = 200;`

---

## 4. Description Header

Every Apex class and trigger MUST begin with this exact header (all fields required):

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
                :
************************************************************************************************/
```

Flag any class or trigger missing this header or with any field left blank.

---

## 5. Code Indentation & Commenting

- Indentation must be consistent throughout the file.
- Every class must have a detailed description in the header AND meaningful inline comments.
- Section and method headers inside a class must use `// ===` style — NOT `/** */` block comment style:

```apex
// ========================================
// Method description
// ========================================
```

---

## 6. Trigger Rules

- Each trigger must handle **ONE event type only** (e.g. `after insert`).
- Trigger body must **only** instantiate the handler and call its method — **no business logic in the trigger**.
- Always include summary debug lines at the end of the trigger:

```apex
trigger AH_Task_AfterInsert on Task (after insert)
{
    AH_Task_TriggerHandler handler = new AH_Task_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);

    system.debug('  AH_Task_AfterInsert SUMMARY: ');
    system.debug('  Limits.getQueries() = ' + Limits.getQueries());
}
```

---

## 7. Trigger Handler Class Rules

### Public Entry Method Signatures

Trigger handlers must expose these exact public entry method signatures and no others:

```apex
public void OnBeforeInsert(List<OBJECTNAME__c> newTrigger) {}
public void OnBeforeUpdate(List<OBJECTNAME__c> newTrigger) {}
public void OnBeforeDelete(List<OBJECTNAME__c> newTrigger) {}
public void OnAfterInsert(List<OBJECTNAME__c> newTrigger) {}
public void OnAfterUpdate(List<OBJECTNAME__c> newTrigger, Map<Id, OBJECTNAME__c> mapOldTrigger) {}
public void OnAfterDelete(List<OBJECTNAME__c> newTrigger) {}
public void OnAfterUnDelete(List<OBJECTNAME__c> newTrigger) {}
```

### Private Method Rules
- Public entry methods must only call private methods — keep them lean (control execution order only).
- **No additional public methods** inside trigger handler classes.
- If a function must be called by other classes, it must live in a **separate public static class**.

### Bypass Switch
Every trigger handler class MUST include the `NI_TriggerBypassSwitches__c` bypass pattern:

```apex
public class AH_SomeObjectName_TriggerHandler
{
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}

    public AH_SomeObjectName_TriggerHandler()
    {
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }

    public void OnBeforeUpdate(List<SomeObjectName__c> newTrigger)
    {
        if (!bpSwitch.BypassSomeObjectName__c)
        {
            // calls to private methods here
        }
    }
}
```

---

## 8. Coding Practices

### ❌ Ternary Operators — NEVER USE

```apex
// ❌ Not allowed
x = y != null ? y : 0;

// ✅ Required
x = 0;
if (y != null)
{
    x = y;
}
```

### ✅ Curly Brackets — Always required, even for single-line `if`

```apex
// ❌ Not allowed
if (i == 1)
    j = 2;

// ✅ Required
if (i == 1)
{
    j = 2;
}
```

### `else if` — Use sparingly
Prefer nested `else { if {} }` over `else if` chains except for switch-style replacements:

```apex
if (i == 1)
{
    j = 2;
}
else
{
    if (i == 2)
    {
        j = 3;
    }
}
```

### `system.debug` Statements
- Remove debug statements unless they are meaningful to other developers.
- Always retain error-related debugs:

```apex
catch (exception e)
{
    system.debug('Error occurred : ' + e.getMessage());
}
```

---

## 9. Error Handling & Logging

- Use `NI_Error_Logger` for all Apex/platform errors — writes to `NI_Admin_Error_Log__c`.
- Use `DTS_Integration_Logger` for integration callout exceptions — writes to `DTS_Integration_Log__c`.
- All exceptions must be caught, logged, and surfaced to users appropriately based on severity.
- Flag any bare `catch` block with no logging.

---

## 10. Test Classes

### Coverage Requirements
- Every Apex class must have its own dedicated test class.
- Minimum **80% test coverage** required before deployment.

### Test Data Rules
- **NEVER** create test records inline inside test methods.
- **Always** use `NI_TestClassData` static class for all test record creation.

### Test Class Structure

```apex
/***********************************************************************************************
Name            : AH_SomeObject_TriggerHandler_Test
Author          : 
Created Date    : 
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Test Class for AH_SomeObject_TriggerHandler
************************************************************************************************/
@isTest
private class AH_SomeObject_TriggerHandler_Test
{
    // ================================================================================
    // = CREATE TEST DATA
    // ================================================================================
    @testSetup static void createTestData()
    {
        Test.startTest();

        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_SomeObject_TriggerHandler_Test Account';
        insert a;

        Test.stopTest();
    }

    // ================================================================================
    // = TEST METHOD 1: <description>
    // ================================================================================
    @isTest static void test1()
    {
        Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'AH_SomeObject_TriggerHandler_Test Account'];

        Test.startTest();
        system.assertEquals(UserInfo.getUserId(), a.OwnerId);
        Test.stopTest();
    }
}
```

> ⚠️ Do NOT include `NI_TestClassData` in any change sets — update it manually and distribute changes via email.

---

## 11. Deployment Rules

- All change sets must be validated with proper coverage before deployment.
- No changes may be deployed without an approved NI Change Request.
- One developer acts as the gatekeeper for ALL deployments to SBFULL & PROD.

---

## 12. PR Review Violation Report Format

For every violation found, report using this format:

```
Line <N>: [<CODE>] <description>
→ Fix: <suggested correction>
```

### Rule Codes

| Code         | Category                              |
|--------------|---------------------------------------|
| `NAMING-001` | Class/file name mismatch or wrong pattern |
| `NAMING-002` | Method name violates convention       |
| `NAMING-003` | Variable name violates convention     |
| `NAMING-004` | Constant not in UPPER_SNAKE_CASE      |
| `HEADER-001` | Missing or incomplete description header |
| `TRIGGER-001`| Logic found directly in trigger body  |
| `TRIGGER-002`| Trigger handles multiple event types  |
| `TRIGGER-003`| Missing summary debug lines           |
| `HANDLER-001`| Missing bypass switch                 |
| `HANDLER-002`| Public method added to trigger handler|
| `CODE-001`   | Ternary operator used                 |
| `CODE-002`   | Missing curly brackets on if/else     |
| `CODE-003`   | Unnecessary or missing debug statement|
| `ERROR-001`  | Missing error logging in catch block  |
| `TEST-001`   | Test data created inline (not via NI_TestClassData) |
| `TEST-002`   | Missing or insufficient test coverage |
| `DEPLOY-001` | Missing NI Change Request reference   |

---

If no violations are found, respond with:

```
✅ PR passed all Amadeus Hospitality Apex code standards.
```
