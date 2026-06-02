public with sharing class GetSegmentMembershipAction {

    @InvocableMethod(label='Get Segment Membership'
                     description='Returns Data Cloud segment membership for a client')
    public static List<String> execute(List<String> contactIds) {
        List<String> results = new List<String>();
        for (String contactId : contactIds) {
            try {
                Contact c = [
                    SELECT DriftAlertSegment__c, ChurnRiskSegment__c,
                           PortfolioDrift__c, LastAdvisorContact__c
                    FROM Contact WHERE Id = :contactId
                    WITH USER_MODE LIMIT 1
                ];

                List<String> segments = new List<String>();
                if (String.isNotBlank(c.DriftAlertSegment__c)) {
                    segments.add('DRIFT ALERT — Portfolio drift of '
                        + c.PortfolioDrift__c + '% exceeds 5% threshold.');
                }
                if (String.isNotBlank(c.ChurnRiskSegment__c)) {
                    String lastContact = c.LastAdvisorContact__c != null
                        ? c.LastAdvisorContact__c.format() : 'never';
                    segments.add('CHURN RISK — Last advisor contact: ' + lastContact + '.');
                }
                results.add(segments.isEmpty()
                    ? 'This client is not currently in any alert segment.'
                    : String.join(segments, '\n'));
            } catch (Exception e) {
                results.add('Error: ' + e.getMessage());
            }
        }
        return results;
    }
}
