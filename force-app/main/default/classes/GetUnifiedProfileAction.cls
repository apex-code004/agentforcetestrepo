public with sharing class GetUnifiedProfileAction {

    @InvocableMethod(label='Get Unified Client Profile'
                     description='Returns unified client profile for Agentforce agent')
    public static List<String> execute(List<String> contactIds) {
        List<String> results = new List<String>();
        for (String contactId : contactIds) {
            try {
                Contact c = AgentActionController.getContactForAgent(contactId);
                Map<String, Object> profile = new Map<String, Object>{
                    'name'               => c.FirstName + ' ' + c.LastName,
                    'riskTolerance'      => c.RiskTolerance__c,
                    'portfolioDriftPct'  => c.PortfolioDrift__c,
                    'driftAlertActive'   => String.isNotBlank(c.DriftAlertSegment__c),
                    'churnRiskActive'    => String.isNotBlank(c.ChurnRiskSegment__c),
                    'lastAdvisorContact' => c.LastAdvisorContact__c != null
                                           ? c.LastAdvisorContact__c.format() : 'Never',
                    'advisor'            => c.Owner.Name,
                    'activeAccountCount' => c.FinancialAccounts__r.size()
                };
                results.add(JSON.serialize(profile));
            } catch (Exception e) {
                results.add('{"error":"' + e.getMessage() + '"}');
            }
        }
        return results;
    }
}
