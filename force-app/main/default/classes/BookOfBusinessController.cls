public with sharing class BookOfBusinessController {

    @AuraEnabled(cacheable=true)
    public static List<ClientSummary> getBookOfBusiness(String segmentFilter) {
        Id currentUserId = UserInfo.getUserId();

        String query =
            'SELECT Id, FirstName, LastName, Email, ' +
            '       RiskTolerance__c, PortfolioDrift__c, ' +
            '       DriftAlertSegment__c, ChurnRiskSegment__c, ' +
            '       LastAdvisorContact__c, ' +
            '       (SELECT TotalValue__c FROM FinancialAccounts__r ' +
            '        WHERE Status__c = \'Active\') ' +
            'FROM Contact ' +
            'WHERE OwnerId = :currentUserId ';

        if (segmentFilter == 'Drift Alert') {
            query += 'AND DriftAlertSegment__c != null ';
        } else if (segmentFilter == 'Churn Risk') {
            query += 'AND ChurnRiskSegment__c != null ';
        } else if (segmentFilter == 'High Risk') {
            query += 'AND RiskTolerance__c IN (\'Aggressive\', \'Speculative\') ';
        }

        query += 'ORDER BY PortfolioDrift__c DESC NULLS LAST LIMIT 200';

        List<Contact> contacts = Database.query(query);
        List<ClientSummary> summaries = new List<ClientSummary>();

        for (Contact c : contacts) {
            ClientSummary cs       = new ClientSummary();
            cs.contactId           = c.Id;
            cs.fullName            = c.FirstName + ' ' + c.LastName;
            cs.email               = c.Email;
            cs.riskTolerance       = c.RiskTolerance__c;
            cs.driftPct            = c.PortfolioDrift__c;
            cs.driftAlertActive    = String.isNotBlank(c.DriftAlertSegment__c);
            cs.churnRiskActive     = String.isNotBlank(c.ChurnRiskSegment__c);
            cs.lastContact         = c.LastAdvisorContact__c;

            Decimal totalAUM = 0;
            for (FinancialAccount__c fa : c.FinancialAccounts__r) {
                totalAUM += fa.TotalValue__c != null ? fa.TotalValue__c : 0;
            }
            cs.totalAUM = totalAUM;
            summaries.add(cs);
        }
        return summaries;
    }

    public class ClientSummary {
        @AuraEnabled public Id       contactId;
        @AuraEnabled public String   fullName;
        @AuraEnabled public String   email;
        @AuraEnabled public String   riskTolerance;
        @AuraEnabled public Decimal  driftPct;
        @AuraEnabled public Boolean  driftAlertActive;
        @AuraEnabled public Boolean  churnRiskActive;
        @AuraEnabled public Decimal  totalAUM;
        @AuraEnabled public DateTime lastContact;
    }
}
