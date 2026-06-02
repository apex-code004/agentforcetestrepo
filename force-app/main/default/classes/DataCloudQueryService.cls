public with sharing class DataCloudQueryService {

    private static final String DC_NAMED_CREDENTIAL = 'callout:DataCloud_QueryAPI';

    public static String getHoldingsSummary(String contactId) {
        try {
            Contact c = [
                SELECT DCUnifiedIndividualId__c
                FROM Contact WHERE Id = :contactId
                WITH USER_MODE LIMIT 1
            ];

            if (String.isBlank(c.DCUnifiedIndividualId__c)) {
                return '{"error":"No unified Data Cloud profile found for this client."}';
            }

            String unifiedId = String.escapeSingleQuotes(c.DCUnifiedIndividualId__c);
            String sql =
                'SELECT AssetClass__c, ' +
                'SUM(Amount__c) AS TotalValue, ' +
                'COUNT(Id) AS TransactionCount ' +
                'FROM PortfolioTransactionDMO__dlm pt ' +
                'JOIN FinancialAccountDMO__dlm fa ON pt.FinancialAccountId = fa.Id ' +
                'JOIN Individual__dlm ind ON fa.IndividualId = ind.Id ' +
                'WHERE ind.UnifiedRecordId = \'' + unifiedId + '\' ' +
                'AND pt.TransactionDate__c >= DATEADD(DAY, -90, TODAY()) ' +
                'GROUP BY AssetClass__c ' +
                'ORDER BY TotalValue DESC';

            HttpRequest req = new HttpRequest();
            req.setEndpoint(DC_NAMED_CREDENTIAL + '/api/v1/query');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(new Map<String, String>{ 'sql' => sql }));
            req.setTimeout(10000);

            HttpResponse res = new Http().send(req);

            if (res.getStatusCode() == 200) {
                return res.getBody();
            }
            return '{"error":"DC Query API returned ' + res.getStatusCode() + '"}';

        } catch (Exception e) {
            return '{"error":"' + e.getMessage() + '"}';
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<PortfolioHolding__c> getHoldingsWithMarketData(Id contactId) {
        List<Id> accountIds = new List<Id>();
        for (FinancialAccount__c fa : [
            SELECT Id FROM FinancialAccount__c
            WHERE ContactId__c = :contactId AND Status__c = 'Active'
            WITH USER_MODE
        ]) {
            accountIds.add(fa.Id);
        }

        return [
            SELECT Id, Ticker__c, AssetClass__c, Quantity__c,
                   CurrentValue__c, CurrentAllocationPct__c,
                   AsOfDate__c, FinancialAccountId__r.AccountNumber__c
            FROM PortfolioHolding__c
            WHERE FinancialAccountId__c IN :accountIds
            WITH USER_MODE
            ORDER BY CurrentValue__c DESC NULLS LAST
        ];
    }
}
