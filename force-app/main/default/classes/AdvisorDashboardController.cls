public with sharing class AdvisorDashboardController {

    @AuraEnabled(cacheable=true)
    public static AdvisorDashboardData getDashboardData(Id contactId) {
        try {
            AdvisorDashboardData data = new AdvisorDashboardData();

            data.client = [
                SELECT Id, FirstName, LastName, Email, Phone,
                       RiskTolerance__c, PortfolioDrift__c,
                       DriftAlertSegment__c, ChurnRiskSegment__c,
                       LastAdvisorContact__c, OwnerId, Owner.Name
                FROM Contact
                WHERE Id = :contactId
                WITH USER_MODE
                LIMIT 1
            ];

            data.accounts = [
                SELECT Id, Name, AccountNumber__c, AccountType__c,
                       TotalValue__c, TargetEquityPct__c,
                       TargetBondPct__c, TargetCashPct__c, Status__c
                FROM FinancialAccount__c
                WHERE ContactId__c = :contactId
                WITH USER_MODE
                ORDER BY TotalValue__c DESC NULLS LAST
            ];

            Set<Id> accountIds = new Map<Id, FinancialAccount__c>(data.accounts).keySet();
            data.holdings = [
                SELECT Id, Ticker__c, AssetClass__c, Quantity__c,
                       CurrentValue__c, CurrentAllocationPct__c, AsOfDate__c,
                       FinancialAccountId__c
                FROM PortfolioHolding__c
                WHERE FinancialAccountId__c IN :accountIds
                WITH USER_MODE
                ORDER BY CurrentValue__c DESC NULLS LAST
                LIMIT 10
            ];

            data.alerts = [
                SELECT Id, Name, DriftPct__c, AlertStatus__c,
                       TriggerSource__c, DetectedAt__c, FinancialAccountId__c,
                       FinancialAccountId__r.AccountNumber__c
                FROM DriftAlert__c
                WHERE ContactId__c = :contactId
                  AND AlertStatus__c IN ('New', 'In Progress')
                WITH USER_MODE
                ORDER BY DetectedAt__c DESC
                LIMIT 5
            ];

            AggregateResult[] agg = [
                SELECT SUM(TotalValue__c) totalAUM
                FROM FinancialAccount__c
                WHERE ContactId__c = :contactId
                  AND Status__c = 'Active'
                WITH USER_MODE
            ];
            data.totalAUM = (Decimal) agg[0].get('totalAUM');

            return data;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to load dashboard data: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void resolveAlert(Id alertId) {
        try {
            DriftAlert__c alert = [
                SELECT Id, AlertStatus__c FROM DriftAlert__c
                WHERE Id = :alertId WITH USER_MODE LIMIT 1
            ];
            alert.AlertStatus__c = 'Resolved';
            alert.ResolvedAt__c   = DateTime.now();
            update as user alert;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to resolve alert: ' + e.getMessage());
        }
    }

    public class AdvisorDashboardData {
        @AuraEnabled public Contact                    client;
        @AuraEnabled public List<FinancialAccount__c>  accounts;
        @AuraEnabled public List<PortfolioHolding__c>  holdings;
        @AuraEnabled public List<DriftAlert__c>        alerts;
        @AuraEnabled public Decimal                    totalAUM;
    }
}
