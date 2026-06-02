import { LightningElement, api } from 'lwc';

const COLUMNS = [
    { label: 'Ticker',      fieldName: 'Ticker__c',              type: 'text'     },
    { label: 'Asset Class', fieldName: 'AssetClass__c',          type: 'text'     },
    { label: 'Value',       fieldName: 'CurrentValue__c',        type: 'currency',
      typeAttributes: { currencyCode: 'USD', maximumFractionDigits: 0 }, sortable: true },
    { label: 'Alloc %',     fieldName: 'CurrentAllocationPct__c',type: 'percent',
      typeAttributes: { maximumFractionDigits: 1 } }
];

export default class PortfolioSummaryCard extends LightningElement {

    @api accounts = [];
    @api holdings = [];

    holdingColumns = COLUMNS;

    get hasAccounts() { return this.accounts && this.accounts.length > 0; }
    get hasHoldings() { return this.holdings && this.holdings.length > 0; }
}
