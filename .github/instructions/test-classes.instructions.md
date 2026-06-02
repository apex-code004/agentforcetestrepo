---
applyTo: "**/*_Test.cls"
---

# Amadeus Hospitality – Test Class Rules

## Naming
- File name: `<ClassOrTriggerBeingTested>_Test.cls`
- Example: `AH_Account_TriggerHandler_Test.cls`

## Coverage Requirement
- Minimum **80% coverage** is required before any deployment
- Every Apex class must have its OWN dedicated test class — shared test classes are not acceptable

## Test Data — CRITICAL RULE
- ❌ NEVER create test records (Account, Contact, etc.) inline inside a test class
- ✅ ALWAYS use `NI_TestClassData` static class for all record creation
- This ensures a single place to fix issues from new required fields or validation rules

```apex
// CORRECT
Account a = NI_TestClassData.createTestAccount(1);
a.Name = 'MyTest Account';
insert a;

// WRONG — do not do this
Account a = new Account(Name = 'Test');
insert a;
```

> NOTE: Do NOT include `NI_TestClassData` in change sets. Update it manually and notify the team by email.

## Required Test Class Structure

```apex
/***********************************************************************************************
Name            : AH_<ObjectName>_TriggerHandler_Test
Author          : 
Created Date    : 
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Test Class for AH_<ObjectName>_TriggerHandler
                :
************************************************************************************************/
@isTest
private class AH_<ObjectName>_TriggerHandler_Test
{
    // ================================================================================
    // = CREATE TEST DATA
    // ================================================================================
    @testSetup static void createTestData()
    {
        Test.startTest();

        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_<ObjectName>_TriggerHandler_Test Account';
        insert a;

        Test.stopTest();
    }

    // ================================================================================
    // = TEST METHOD 1: <description of what is being tested>
    // ================================================================================
    @isTest static void test1()
    {
        Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'AH_<ObjectName>_TriggerHandler_Test Account'];

        Test.startTest();

        system.assertEquals(UserInfo.getUserId(), a.OwnerId);

        Test.stopTest();
    }
}
```

## Rules
- ✅ Use `@testSetup` for shared test data across all test methods
- ✅ Each test method wrapped in `Test.startTest()` / `Test.stopTest()`
- ✅ Use `system.assertEquals` / `system.assertNotEquals` for assertions
- ✅ Use `// ===` style section headers between test methods
- ❌ No inline record creation — use `NI_TestClassData` only
- ❌ No `NI_TestClassData` in change sets
