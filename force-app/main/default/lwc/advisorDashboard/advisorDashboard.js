import { LightningElement, api, wire, track } from 'lwc';
import getDashboardData from '@salesforce/apex/AdvisorDashboardController.getDashboardData';
import resolveAlert from '@salesforce/apex/AdvisorDashboardController.resolveAlert';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class AdvisorDashboard extends LightningElement {

    @api recordId;

    @track dashboardData;
    @track isLoading = true;
    @track errorMessage;

    _wiredResult;

    @wire(getDashboardData, { contactId: '$recordId' })
    wiredDashboard(result) {
        this._wiredResult = result;
        this.isLoading = false;
        if (result.data) {
            this.dashboardData = result.data;
            this.errorMessage  = null;
        } else if (result.error) {
            this.errorMessage = result.error.body?.message || 'Unknown error';
        }
    }

    get hasData()  { return !!this.dashboardData; }
    get hasError() { return !!this.errorMessage;  }

    async handleAlertResolved(event) {
        const alertId = event.detail.alertId;
        try {
            await resolveAlert({ alertId });
            this.dispatchEvent(new ShowToastEvent({
                title:   'Alert resolved',
                message: 'Drift alert has been marked as resolved.',
                variant: 'success'
            }));
            await refreshApex(this._wiredResult);
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({
                title:   'Error',
                message: e.body?.message || 'Could not resolve alert.',
                variant: 'error'
            }));
        }
    }
}
