public with sharing class QueryHoldingsAction {

    @InvocableMethod(label='Query Portfolio Holdings from Data Cloud'
                     description='Calls DC Query API for real-time holding allocation')
    public static List<String> execute(List<String> contactIds) {
        List<String> results = new List<String>();
        for (String contactId : contactIds) {
            results.add(DataCloudQueryService.getHoldingsSummary(contactId));
        }
        return results;
    }
}
