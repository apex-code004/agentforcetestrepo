/**
 * Router class for shared logic — individual @InvocableMethod actions
 * are split into GetUnifiedProfileAction, QueryHoldingsAction,
 * and GetSegmentMembershipAction (Salesforce allows only one per class).
 */
public with sharing class AgentActionController {

    public static Contact getContactForAgent(String contactId) {
        return [
            SELECT Id, FirstName, LastName, RiskTolerance__c,
                   PortfolioDrift__c, DriftAlertSegment__c,
                   ChurnRiskSegment__c, LastAdvisorContact__c,
                   Owner.Name,
                   (SELECT TotalValue__c, AccountType__c, Status__c
                    FROM FinancialAccounts__r
                    WHERE Status__c = 'Active')
            FROM Contact
            WHERE Id = :contactId
            WITH USER_MODE
            LIMIT 1
        ];
    }
}
