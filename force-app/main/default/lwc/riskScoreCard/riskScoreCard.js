import { LightningElement, api } from 'lwc';

export default class RiskScoreCard extends LightningElement {

    @api client;
    @api totalAUM;

    get hasDriftAlert()  { return this.client?.DriftAlertSegment__c; }
    get hasChurnRisk()   { return this.client?.ChurnRiskSegment__c;  }
    get advisorName()    { return this.client?.Owner?.Name || '—';   }

    get driftClass() {
        const drift = this.client?.PortfolioDrift__c || 0;
        return drift > 5
            ? 'slds-text-heading_medium slds-text-color_error'
            : 'slds-text-heading_medium slds-text-color_success';
    }

    get riskBadgeClass() {
        const risk = this.client?.RiskTolerance__c;
        if (risk === 'Speculative' || risk === 'Aggressive') return 'slds-theme_error';
        if (risk === 'Moderate') return 'slds-theme_warning';
        return 'slds-theme_success';
    }
}
