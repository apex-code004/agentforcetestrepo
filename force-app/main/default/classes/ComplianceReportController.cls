public with sharing class ComplianceReportController {

    @AuraEnabled(cacheable=true)
    public static List<AgentInteraction__c> getEscalatedInteractions(
            Date startDate, Date endDate) {

        return [
            SELECT Id, QueryText__c, EscalationReason__c, AgentTopic__c,
                   InteractionTime__c,
                   AdvisorId__c, AdvisorId__r.Name,
                   ContactId__c, ContactId__r.Name
            FROM AgentInteraction__c
            WHERE WasEscalated__c = TRUE
              AND InteractionTime__c >= :DateTime.newInstance(startDate, Time.newInstance(0,0,0,0))
              AND InteractionTime__c <= :DateTime.newInstance(endDate, Time.newInstance(23,59,59,0))
            WITH USER_MODE
            ORDER BY InteractionTime__c DESC
            LIMIT 1000
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<DriftAlert__c> getDriftAlertHistory(Id contactId) {
        return [
            SELECT Id, DriftPct__c, AlertStatus__c, TriggerSource__c,
                   DetectedAt__c, ResolvedAt__c,
                   FinancialAccountId__r.AccountNumber__c
            FROM DriftAlert__c
            WHERE ContactId__c = :contactId
            WITH USER_MODE
            ORDER BY DetectedAt__c DESC
            LIMIT 50
        ];
    }
}
