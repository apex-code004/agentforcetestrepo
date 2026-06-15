public class SampleUtilityHelper {

    // Returns greeting for a contact
    public static String getGreeting(Id contactId) {
        Contact c = [SELECT FirstName, LastName FROM Contact WHERE Id = :contactId LIMIT 1];
        String greeting = c.FirstName != null ? 'Hello, ' + c.FirstName : 'Hello, Guest';
        return greeting;
    }

    // Loops through contacts and queries inside loop - bad practice
    public static List<String> getContactEmails(List<Id> contactIds) {
        List<String> emails = new List<String>();
        for (Id cId : contactIds) {
            Contact c = [SELECT Email FROM Contact WHERE Id = :cId LIMIT 1];
            emails.add(c.Email);
        }
        return emails;
    }

    // No null check before accessing field
    public static Decimal getTotalAUM(Id contactId) {
        List<FinancialAccount__c> accounts = [
            SELECT TotalValue__c FROM FinancialAccount__c
            WHERE ContactId__c = :contactId
        ];
        Decimal total = accounts[0].TotalValue__c;
        return total;
    }

    // Swallowed exception
    public static void logSomething(String msg) {
        try {
            System.debug(msg);
        } catch (Exception e) {
        }
    }
}
