import { LightningElement, api } from 'lwc';

export default class AlertFeed extends LightningElement {

    @api alerts = [];

    get hasAlerts() { return this.alerts && this.alerts.length > 0; }

    handleResolve(event) {
        const alertId = event.currentTarget.dataset.alertId;
        this.dispatchEvent(new CustomEvent('alertresolved', {
            detail: { alertId },
            bubbles: true,
            composed: true
        }));
    }
}
