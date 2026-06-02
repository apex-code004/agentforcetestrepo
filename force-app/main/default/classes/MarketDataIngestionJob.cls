/**
 * Scheduled Apex job: fetches market prices and pushes to Data Cloud
 * via the Ingestion API.
 *
 * Schedule (run in Execute Anonymous):
 *   System.schedule('Market Data Ingestion', '0 0 1 * * ?', new MarketDataIngestionJob());
 */
public class MarketDataIngestionJob implements Schedulable, Database.Batchable<String> {

    private static final String DC_INGEST_ENDPOINT =
        'callout:DataCloud_QueryAPI/api/v1/ingest/sources/MarketData_Feed/marketdata';

    private static final List<String> TICKERS =
        new List<String>{ 'AAPL','MSFT','NVDA','TSLA','META',
                          'SPY','BND','TLT','VXUS','CASH' };

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 10);
    }

    public Iterable<String> start(Database.BatchableContext bc) {
        return TICKERS;
    }

    public void execute(Database.BatchableContext bc, List<String> tickers) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MarketData_Feed/quotes?symbols='
                        + String.join(tickers, ','));
        req.setMethod('GET');
        req.setTimeout(10000);

        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) return;

        List<Object> rawQuotes = (List<Object>) JSON.deserializeUntyped(res.getBody());

        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for (Object obj : rawQuotes) {
            Map<String, Object> q = (Map<String, Object>) obj;
            records.add(new Map<String, Object>{
                'Id'              => 'MKT-' + q.get('symbol') + '-' + Date.today(),
                'Ticker__c'       => q.get('symbol'),
                'Price__c'        => q.get('price'),
                'DayChangePct__c' => q.get('changePercent'),
                'Sector__c'       => q.get('sector'),
                'AsOfDate__c'     => String.valueOf(Date.today())
            });
        }

        HttpRequest ingestReq = new HttpRequest();
        ingestReq.setEndpoint(DC_INGEST_ENDPOINT);
        ingestReq.setMethod('POST');
        ingestReq.setHeader('Content-Type', 'application/json');
        ingestReq.setBody(JSON.serialize(new Map<String, Object>{ 'data' => records }));
        ingestReq.setTimeout(15000);
        new Http().send(ingestReq);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('MarketDataIngestionJob complete: ' + DateTime.now());
    }
}
