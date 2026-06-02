import { LightningElement, api, wire } from 'lwc';
import getHoldingsWithMarketData from '@salesforce/apex/DataCloudQueryService.getHoldingsWithMarketData';

const COLUMNS = [
    { label: 'Ticker',       fieldName: 'Ticker__c',               type: 'text' },
    { label: 'Asset Class',  fieldName: 'AssetClass__c',           type: 'text' },
    { label: 'Quantity',     fieldName: 'Quantity__c',             type: 'number',
      typeAttributes: { maximumFractionDigits: 2 } },
    { label: 'Market Value', fieldName: 'CurrentValue__c',         type: 'currency',
      typeAttributes: { currencyCode: 'USD' }, sortable: true },
    { label: 'Allocation %', fieldName: 'CurrentAllocationPct__c', type: 'number',
      typeAttributes: { maximumFractionDigits: 1 } },
    { label: 'As Of',        fieldName: 'AsOfDate__c',             type: 'date' }
];

const ASSET_CLASSES = [
    'Equity - US',
    'Equity - International',
    'Fixed Income - Government',
    'Fixed Income - Corporate',
    'Cash & Equivalents'
];

export default class HoldingsAnalyser extends LightningElement {

    @api recordId;
    holdingColumns = COLUMNS;
    holdings = [];

    @wire(getHoldingsWithMarketData, { contactId: '$recordId' })
    wiredHoldings({ data }) {
        if (data) this.holdings = data;
    }

    get allocationRows() {
        return ASSET_CLASSES.map(cls => {
            const holding = this.holdings.find(h => h.AssetClass__c === cls);
            const current = holding ? Math.round(holding.CurrentAllocationPct__c || 0) : 0;
            return {
                assetClass: cls,
                currentPct: current,
                targetPct:  0,
                variant:    current > 75 ? 'warning' : 'base'
            };
        });
    }
}
