# Amadeus Hospitality — Copilot Instructions

This is a **Salesforce DX project** following **Amadeus Hospitality Apex development standards**.

When reviewing any Pull Request or generating any code, enforce ALL rules below without exception.
Do NOT approve or suggest merging code that violates any mandatory rule marked with ❌.

---

## Repository structure

```
.github/
  agents/         → AI coding agents (Apex review, SOQL optimizer, ESLint fixer)
  instructions/   → Path-scoped coding standards (applied per file type)
  skills/         → Reusable rule sets loaded by agents
  scripts/        → Python automation scripts (apex_review.py, run_agent.py)
  workflows/      → GitHub Actions CI/CD pipelines
```

- CI runs on every PR: static analysis (Apex agent + ESLint + Salesforce Code Analyzer) and SonarQube scan
- Apex review agent is triggered by the label `apex-review` or the comment `/apex-review` on a PR
- All deployments require an approved NI Change Request before merging

---

## 1. Naming conventions

### Apex classes

| Artifact | Pattern | Example |
|---|---|---|
| Standard class | `AH_<Name>` | `AH_Functions` |
| Trigger | `AH_<Object>_<Event>` | `AH_Task_AfterInsert` |
| Trigger handler | `AH_<ObjectName>_TriggerHandler` | `AH_Account_TriggerHandler` |
| Batchable class | `AH_<Name>_Batch` | `AH_Functions_Batch` |
| Schedulable class | `AH_<Name>_Schedule` | `AH_Functions_Schedule` |
| Queueable class | `AH_<Name>_Queueable` | `AH_Functions_Queueable` |
| Mock class | `AH_<Name>_Mock` | `AH_Functions_Mock` |
| Test class | `<ClassOrTriggerName>_Test` | `AH_Account_TriggerHandler_Test` |
| Controller extension | `<VFPageName>_Ext` | `AH_SolutionSearch_Ext` |
| Service class | `AH_<Object>_Service` | `AH_Account_Service` |
| Selector class | `AH_<Object>_Selector` | `AH_Account_Selector` |
| Custom exception | `AH_<Domain>_Exception` | `AH_Account_Exception` |
| API client | `AH_<APIName>_ApiClient` | `AH_Stripe_ApiClient` |
| Request wrapper | `AH_<APIName>_Request` | `AH_Stripe_Request` |
| Response wrapper | `AH_<APIName>_Response` | `AH_Stripe_Response` |
| API client mock | `AH_<APIName>_ApiClientMock` | `AH_Stripe_ApiClientMock` |

### Integration components
- Use `INTGR_<Acronym>_<Name>` — NOT `AH_` prefix
- Example: `INTGR_WinSN_Case_Handler`

### Visualforce pages & components
- Must be prefixed with `AH_` — e.g. `AH_SolutionSearch`

> ⚠️ All names MUST be approved before use. If a name is not in the project/SOW, flag it in the PR review.

### Method naming

- Use `camelCase` for all method names
- Boolean methods must start with `is`, `has`, or `can` — e.g. `isEligible()`, `hasOpenCases()`
- Trigger handler public entry methods use PascalCase matching the event:
  `OnBeforeInsert()`, `OnBeforeUpdate()`, `OnBeforeDelete()`, `OnAfterInsert()`, `OnAfterUpdate()`, `OnAfterDelete()`, `OnAfterUnDelete()`
- Service methods use verb-noun form — e.g. `createTasks()`, `updateAccountStatus()`
- Selector methods start with `get` — e.g. `getById()`, `getByAccountId()`

### Variable naming

- Collections use plural nouns — `List<Account> accounts`, `Map<Id, Contact> contactMap`
- Loop variables use singular — `for (Account acc : accounts)`
- ID sets suffix with `Ids` — `Set<Id> accountIds`
- Maps suffix with `Map` — `Map<Id, Account> accountMap`
- Constants in `UPPER_SNAKE_CASE` — `private static final Integer MAX_RECORDS = 200;`

**Violation codes:** `NAMING-001` (class/file), `NAMING-002` (method), `NAMING-003` (variable), `NAMING-004` (constant)

---

## 2. Description header — mandatory on every class and trigger

Every single Apex class and trigger MUST begin with this exact header block. All fields are required — flag any that are blank or missing.

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

❌ Any class or trigger missing this header is an immediate violation — `HEADER-001`.

---

## 3. Code indentation and commenting

- Indentation must be consistent throughout every file
- Every class must have a detailed description in the header AND meaningful inline comments
- Section and method headers inside a class MUST use `// ===` style — never `/** */` block comments

```apex
// ========================================
// Method description
// ========================================
```

---

## 4. Triggers

- Each trigger handles **ONE event type only** — never combine `before insert, after insert` in one trigger
- Trigger body MUST only instantiate the handler and call its method — no business logic, SOQL, or DML inside the trigger
- Always add summary debug lines at the end

```apex
/***********************************************************************************************
Name            : AH_Task_AfterInsert
Author          : 
Created Date    : 
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Call the AfterInsert methods in AH_Task_TriggerHandler
                :
************************************************************************************************/
trigger AH_Task_AfterInsert on Task (after insert)
{
    AH_Task_TriggerHandler handler = new AH_Task_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);

    system.debug('  AH_Task_AfterInsert SUMMARY: ');
    system.debug('  Limits.getQueries() = ' + Limits.getQueries());
}
```

**Violation codes:** `TRIGGER-001` (logic in trigger body), `TRIGGER-002` (multiple event types), `TRIGGER-003` (missing summary debug lines)

---

## 5. Trigger handler classes

### Required public entry method signatures (use exactly these — no others)

```apex
public void OnBeforeInsert(List<OBJECTNAME__c> newTrigger) {}
public void OnBeforeUpdate(List<OBJECTNAME__c> newTrigger) {}
public void OnBeforeDelete(List<OBJECTNAME__c> newTrigger) {}
public void OnAfterInsert(List<OBJECTNAME__c> newTrigger) {}
public void OnAfterUpdate(List<OBJECTNAME__c> newTrigger, Map<Id, OBJECTNAME__c> mapOldTrigger) {}
public void OnAfterDelete(List<OBJECTNAME__c> newTrigger) {}
public void OnAfterUnDelete(List<OBJECTNAME__c> newTrigger) {}
```

### Private methods
- Public entry methods call private methods only — keep entry methods lean (control execution order only)
- ❌ NO additional public methods inside trigger handler classes
- If a function must be called by other classes, it must live in a **separate public static class**

### Bypass switch — mandatory in every trigger handler

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

**Violation codes:** `HANDLER-001` (missing bypass switch), `HANDLER-002` (public method added to handler)

---

## 6. Coding practices

### ❌ Ternary operators — NEVER USE

```apex
// ❌ Forbidden
x = y != null ? y : 0;

// ✅ Required
x = 0;
if (y != null)
{
    x = y;
}
```

### ✅ Curly brackets — always required, even for single-line if statements

```apex
// ❌ Forbidden
if (i == 1)
    j = 2;

// ✅ Required
if (i == 1)
{
    j = 2;
}
```

### else if — use sparingly
Prefer nested `else { if {} }` over `else if` chains, except as switch-style replacements:

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

### system.debug statements
- Remove debug statements unless they are meaningful to other developers
- Always retain error-related debugs:

```apex
catch (exception e)
{
    system.debug('Error occurred : ' + e.getMessage());
}
```

**Violation codes:** `CODE-001` (ternary operator), `CODE-002` (missing curly brackets), `CODE-003` (unnecessary debug)

---

## 7. Error handling and logging

- Use `NI_Error_Logger` for ALL Apex/platform errors — writes to `NI_Admin_Error_Log__c`
- Use `DTS_Integration_Logger` for ALL integration callout exceptions — writes to `DTS_Integration_Log__c`
- All exceptions must be caught, logged, and surfaced to users appropriately
- ❌ Never swallow exceptions silently (empty catch blocks are a critical violation)
- ❌ Never log only `e.getMessage()` — always include `e.getStackTraceString()` as well
- ❌ Never use `AuraHandledException(e.getMessage())` — pass a user-friendly message instead
- ❌ Never wrap an entire method body in one broad try-catch — narrow the try block to the risky operation only

```apex
catch (Exception e)
{
    NI_Error_Logger.logError('AH_ClassName', e.getMessage());
    system.debug('Error occurred : ' + e.getMessage());
}
```

For integrations:
```apex
catch (Exception e)
{
    DTS_Integration_Logger.logError('INTGR_Acronym_ClassName', e.getMessage());
    system.debug('Integration error occurred : ' + e.getMessage());
}
```

**Violation codes:** `ERROR-001` (missing error logging), `EX-001` (empty catch), `EX-002` (overly broad catch), `EX-003` (generic exception thrown), `EX-004` (no stack trace logged), `EX-007` (raw AuraHandledException message)

---

## 8. SOQL governor limits

### ❌ Never put SOQL inside a loop

```apex
// ❌ Forbidden
for (Account acc : accounts)
{
    List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
}

// ✅ Required — bulk query outside the loop
Map<Id, List<Contact>> contactMap = new Map<Id, List<Contact>>();
List<Contact> allContacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds];
for (Contact c : allContacts)
{
    // build the map
}
```

### ❌ Never access query results without checking size first

```apex
// ❌ Forbidden
Account a = [SELECT Id FROM Account WHERE Name = 'X'][0];

// ✅ Required
List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'X'];
if (!accounts.isEmpty())
{
    Account a = accounts[0];
}
```

### SOQL best practices
- Always use specific field names — never `SELECT *` or `FIELDS(ALL)`
- Always add a `WHERE` clause — never do a full table scan
- Always add `LIMIT` unless all records are explicitly needed
- Filter on indexed fields first: `Id`, `Name`, `OwnerId`, `CreatedDate`, `LastModifiedDate`, `RecordTypeId`
- Use parent relationship queries (`Account.Name`) instead of separate queries where possible
- If query could return 10,000+ records, use `Database.Batchable` instead

**Violation codes:** `SOQL-001` (SOQL in loop), `SOQL-002` (redundant query), `SOQL-003` (non-selective filter), `SOQL-004` (unsafe index access), `PERF-001` through `PERF-008`

---

## 9. Bulkification

- Triggers MUST handle lists — never process only `Trigger.new[0]`
- All methods processing records must safely handle 200+ records
- Use `Map` and `Set` for multi-record processing — never repeated single-record queries

```apex
// ❌ Forbidden
public void OnAfterInsert(List<Account__c> newTrigger)
{
    Account__c acc = newTrigger[0];
    // process single record
}

// ✅ Required
public void OnAfterInsert(List<Account__c> newTrigger)
{
    Set<Id> accountIds = new Set<Id>();
    for (Account__c acc : newTrigger)
    {
        accountIds.add(acc.Id);
    }
    // bulk query using the set
}
```

---

## 10. Test classes

### Coverage requirements
- Every Apex class must have its OWN dedicated test class — shared test classes are not acceptable
- Minimum **80% test coverage** required before any deployment

### Test data — critical rule
- ❌ NEVER create test records inline inside a test class
- ✅ ALWAYS use `NI_TestClassData` static class for all record creation
- Do NOT include `NI_TestClassData` in change sets — update it manually and notify the team

```apex
// ✅ Correct
Account a = NI_TestClassData.createTestAccount(1);
a.Name = 'MyTest Account';
insert a;

// ❌ Wrong — never do this
Account a = new Account(Name = 'Test');
insert a;
```

### Required test class structure

```apex
/***********************************************************************************************
Name            : AH_SomeObject_TriggerHandler_Test
Author          : 
Created Date    : 
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Test Class for AH_SomeObject_TriggerHandler
                :
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
    // = TEST METHOD 1: <description of what is being tested>
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

### Test class rules
- ✅ Use `@testSetup` for shared test data across all test methods
- ✅ Each test method wrapped in `Test.startTest()` / `Test.stopTest()`
- ✅ Use `system.assertEquals` / `system.assertNotEquals` for all assertions
- ✅ Include at least one negative test scenario per class
- ✅ Include at least one bulk test (200 records) per trigger handler
- ❌ No hard-coded record IDs in test classes
- ❌ No `seeAllData=true` on test classes

**Violation codes:** `TEST-001` (inline test data), `TEST-002` (missing/insufficient coverage)

---

## 11. Batch and schedulable classes

### Naming
- Batchable: `AH_<Name>_Batch.cls` — e.g. `AH_AccountCleanup_Batch`
- Schedulable: `AH_<Name>_Schedule.cls` — e.g. `AH_AccountCleanup_Schedule`

### Required structure

```apex
public class AH_<Name>_Batch implements Database.Batchable<sObject>
{
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id FROM Object__c]);
    }

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

    public void finish(Database.BatchableContext bc)
    {
    }
}
```

- ✅ Always wrap `execute()` logic in `try/catch`
- ✅ Always log errors via `NI_Error_Logger`
- ❌ Never swallow exceptions silently

---

## 12. Integration classes

### Naming
- Use `INTGR_<Acronym>_<Name>` prefix — NOT `AH_`
- Example: `INTGR_WinSN_Case_Handler`

### Rules
- ✅ All callout exceptions caught and logged via `DTS_Integration_Logger`
- ✅ Description header on every class
- ✅ Always use curly brackets, no ternary operators
- ❌ Never use generic `system.debug` alone for integration errors
- ❌ Never swallow exceptions silently

---

## 13. Security

- All classes must declare `with sharing` or `without sharing` explicitly — never omit it
- SOQL on sensitive objects should use `WITH SECURITY_ENFORCED`
- ❌ No hardcoded credentials, IDs, or tokens anywhere in source code
- ❌ No `seeAllData=true` in test classes

---

## 14. Deployment rules

- All change sets must be validated with proper coverage before deployment
- ❌ No changes may be deployed without an approved **NI Change Request**
- One developer acts as the gatekeeper for ALL deployments to SBFULL & PROD
- Do NOT include `NI_TestClassData` in any change set — update it manually

**Violation code:** `DEPLOY-001` (missing NI Change Request reference)

---

## 15. PR review violation report format

For every violation found, report using this exact format:

```
Line <N>: [<CODE>] <description>
→ Fix: <suggested correction>
```

### All rule codes

| Code | Category |
|---|---|
| `NAMING-001` | Class/file name mismatch or wrong pattern |
| `NAMING-002` | Method name violates convention |
| `NAMING-003` | Variable name violates convention |
| `NAMING-004` | Constant not in UPPER_SNAKE_CASE |
| `HEADER-001` | Missing or incomplete description header |
| `TRIGGER-001` | Logic found directly in trigger body |
| `TRIGGER-002` | Trigger handles multiple event types |
| `TRIGGER-003` | Missing summary debug lines |
| `HANDLER-001` | Missing bypass switch |
| `HANDLER-002` | Public method added to trigger handler |
| `CODE-001` | Ternary operator used |
| `CODE-002` | Missing curly brackets on if/else |
| `CODE-003` | Unnecessary or missing debug statement |
| `ERROR-001` | Missing error logging in catch block |
| `EX-001` | Empty/swallowed catch block |
| `EX-002` | Overly broad catch(Exception e) |
| `EX-003` | Generic exception thrown instead of custom |
| `EX-004` | Exception logged without stack trace |
| `EX-007` | AuraHandledException with raw technical message |
| `SOQL-001` | SOQL inside loop |
| `SOQL-002` | Redundant SOQL query |
| `SOQL-003` | Non-selective filter on large object |
| `SOQL-004` | Unsafe index access on query result |
| `PERF-001` | Non-selective WHERE clause on large object |
| `PERF-002` | SELECT FIELDS(ALL) or all-field fetch |
| `PERF-003` | Missing LIMIT on unbounded query |
| `PERF-004` | ORDER BY on non-indexed field |
| `TEST-001` | Test data created inline (not via NI_TestClassData) |
| `TEST-002` | Missing or insufficient test coverage |
| `DEPLOY-001` | Missing NI Change Request reference |

If no violations are found, respond with:

```
✅ PR passed all Amadeus Hospitality Apex code standards.
```
