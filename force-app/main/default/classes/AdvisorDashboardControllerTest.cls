@IsTest
private class AdvisorDashboardControllerTest {

    @TestSetup
    static void makeData() {
        User advisor = [SELECT Id FROM User
                        WHERE Profile.Name = 'Standard User'
                        AND IsActive = TRUE LIMIT 1];

        Contact client = new Contact(
            FirstName         = 'Test',
            LastName          = 'Client',
            Email             = 'test.client@example.com',
            OwnerId           = advisor.Id,
            RiskTolerance__c  = 'Moderate',
            PortfolioDrift__c = 7.5
        );
        insert client;

        FinancialAccount__c acct = new FinancialAccount__c(
            AccountNumber__c   = 'FA-TEST-001',
            AccountType__c     = 'Individual Brokerage',
            TotalValue__c      = 250000,
            TargetEquityPct__c = 60,
            TargetBondPct__c   = 35,
            TargetCashPct__c   = 5,
            Status__c          = 'Active',
            ContactId__c       = client.Id
        );
        insert acct;

        DriftAlert__c alert = new DriftAlert__c(
            ContactId__c          = client.Id,
            FinancialAccountId__c = acct.Id,
            DriftPct__c           = 7.5,
            AlertStatus__c        = 'New',
            TriggerSource__c      = 'Data Cloud',
            DetectedAt__c         = DateTime.now()
        );
        insert alert;
    }

    @IsTest
    static void testGetDashboardData_success() {
        Contact client = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        AdvisorDashboardController.AdvisorDashboardData data =
            AdvisorDashboardController.getDashboardData(client.Id);
        Test.stopTest();

        Assert.isNotNull(data.client,              'Client should be populated');
        Assert.isTrue(data.accounts.size() > 0,    'Should have accounts');
        Assert.isTrue(data.alerts.size() > 0,      'Should have open alerts');
        Assert.areEqual(250000, data.totalAUM,     'AUM should match');
    }

    @IsTest
    static void testResolveAlert() {
        DriftAlert__c alert = [SELECT Id FROM DriftAlert__c LIMIT 1];
        Test.startTest();
        AdvisorDashboardController.resolveAlert(alert.Id);
        Test.stopTest();

        DriftAlert__c updated = [SELECT AlertStatus__c FROM DriftAlert__c WHERE Id = :alert.Id];
        Assert.areEqual('Resolved', updated.AlertStatus__c, 'Status should be Resolved');
    }

    @IsTest
    static void testGetDashboardData_invalidId() {
        try {
            AdvisorDashboardController.getDashboardData(null);
            Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Script-thrown exception'),
                          'Should be an AuraHandledException');
        }
    }
}
