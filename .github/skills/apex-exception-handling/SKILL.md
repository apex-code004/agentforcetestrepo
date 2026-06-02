---
name: apex-exception-handling
description: Enforces proper Apex exception handling patterns including custom exceptions, no swallowed exceptions, and correct catch-rethrow usage
---
 
Scan the provided Apex code for exception handling anti-patterns that hide errors, cause silent failures, or make debugging in production impossible.
 
## Rules to Check
 
### 1. Swallowed Exceptions (Empty Catch Blocks)
- Detect any `catch` block that is empty or contains only a comment
  e.g., `catch(Exception e) {}` or `catch(Exception e) { // do nothing }`
- Flag as critical — swallowed exceptions hide failures completely
- Suggest at minimum logging the exception: `System.debug(LoggingLevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString());`
- Better: rethrow or throw a custom exception wrapping the original
 
### 2. Catching Generic Exception Too Broadly
- Detect `catch(Exception e)` when a more specific exception type is available
  (e.g., catching `Exception` when only `DmlException` or `CalloutException` is expected)
- Flag each overly broad catch — it masks unexpected errors
- Suggest catching the most specific exception type first, then `Exception` as a fallback
 
### 3. Missing Custom Exception Classes
- Detect code that throws `new AuraHandledException()` or generic `new Exception()` for domain-level errors
- Flag — generic exceptions provide no context for callers
- Suggest creating a domain-specific custom exception class extending `Exception`:
  e.g., `public class AccountException extends Exception {}`
- Custom exceptions should be defined per-domain, not per-class
 
### 4. Exception Message Without Stack Trace Logging
- Detect `catch` blocks that log only `e.getMessage()` without `e.getStackTraceString()`
- Flag — message alone is insufficient for debugging in production
- Suggest logging both: `e.getMessage() + '\n' + e.getStackTraceString()`
 
### 5. Re-throwing Without Wrapping
- Detect `catch(Exception e) { throw e; }` — rethrowing without adding context
- Flag — this loses the call stack context from the catch site
- Suggest wrapping: `throw new MyDomainException('Context: ' + e.getMessage(), e);`
 
### 6. try-catch Around Entire Method Body
- Detect methods where the entire body is wrapped in one large `try-catch`
- Flag as a design smell — broad try blocks catch unintended errors and make it hard to know what failed
- Suggest narrowing the try block to only the risky operation (DML, callout, parsing)
 
### 7. AuraHandledException Without User-Friendly Message
- Detect `throw new AuraHandledException(e.getMessage())` — passes a raw technical message to the UI
- Flag — internal exception messages should not be shown directly to end users
- Suggest a user-friendly message: `throw new AuraHandledException('An error occurred. Please contact your administrator.');`
 
### 8. Exception Handling in Test Classes
- Detect test methods that test exception scenarios without using `try-catch` + `System.assert(false, 'Expected exception not thrown')`
- Flag — without this pattern, tests that should fail silently pass
- Correct pattern:
  ```apex
  try {
      myService.doSomethingInvalid();
      System.assert(false, 'Expected exception was not thrown');
  } catch (MyDomainException e) {
      System.assert(e.getMessage().contains('expected text'), 'Wrong exception message');
  }
  ```
 
## Output Format
 
```
Line <N>: [EX-<CODE>] <short description>
→ Fix: <specific fix suggestion>
```
 
Rule codes:
- `EX-001` — Swallowed / empty catch block
- `EX-002` — Overly broad catch(Exception e)
- `EX-003` — Generic exception thrown instead of custom exception
- `EX-004` — Exception logged without stack trace
- `EX-005` — Re-throw without wrapping
- `EX-006` — Overly broad try block scope
- `EX-007` — AuraHandledException with raw technical message
- `EX-008` — Negative test missing assert(false) pattern
 
If no violations are found, respond with:
```
✅ No exception handling issues detected.
```
 
