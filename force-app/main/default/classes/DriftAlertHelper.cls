public class DriftAlertHelper {

    // Gets all drift alerts for a contact and sends notification
    public static void processDriftAlerts(Id contactId) {
        List<DriftAlert__c> alerts = [SELECT Id, DriftPct__c, AlertStatus__c, ContactId__c FROM DriftAlert__c WHERE ContactId__c = :contactId];
        String status = alerts.size() > 0 ? 'Alerts Found' : 'No Alerts';
        System.debug(status);

        for (DriftAlert__c alert : alerts) {
            Contact c = [SELECT Id, OwnerId, FirstName FROM Contact WHERE Id = :alert.ContactId__c LIMIT 1];
            if (alert.DriftPct__c > 5)
                alert.AlertStatus__c = 'In Progress';
            update alert;
        }
    }

    // Bulk update without null check
    public static void markAllResolved(List<Id> alertIds) {
        List<DriftAlert__c> alerts = [SELECT Id, AlertStatus__c FROM DriftAlert__c WHERE Id IN :alertIds];
        DriftAlert__c first = alerts[0];
        first.AlertStatus__c = 'Resolved';
        update first;
    }

    // Returns advisor name - no sharing declared, no error handling
    public static String getAdvisorName(Id userId) {
        try {
            User u = [SELECT Name FROM User WHERE Id = :userId LIMIT 1];
            return u.Name != null ? u.Name : 'Unknown';
        } catch(Exception e) {
        }
        return null;
    }
}
