import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { MessageContext, publish } from 'lightning/messageService';
import DriftAlertBroadcast from '@salesforce/messageChannel/DriftAlertBroadcast__c';
import getBookOfBusiness from '@salesforce/apex/BookOfBusinessController.getBookOfBusiness';

const COLUMNS = [
    { label: 'Client',      fieldName: 'contactUrl', type: 'url',
      typeAttributes: { label: { fieldName: 'fullName' }, target: '_self' } },
    { label: 'Total AUM',   fieldName: 'totalAUM',   type: 'currency',
      typeAttributes: { currencyCode: 'USD', maximumFractionDigits: 0 }, sortable: true },
    { label: 'Drift %',     fieldName: 'driftPct',   type: 'number',
      typeAttributes: { maximumFractionDigits: 1 }, sortable: true },
    { label: 'Risk',        fieldName: 'riskTolerance', type: 'text' },
    { label: 'Drift Alert', fieldName: 'driftAlertActive', type: 'boolean' },
    { label: 'Actions',     type: 'action', typeAttributes: {
        rowActions: [
            { label: 'View 360',  name: 'view'    },
            { label: 'Log Call',  name: 'logcall' }
        ]
    }}
];

export default class BookOfBusiness extends NavigationMixin(LightningElement) {

    @wire(MessageContext) messageContext;
    @track clients      = [];
    @track isLoading    = true;
    @track activeFilter = 'All';
    columns = COLUMNS;

    @wire(getBookOfBusiness, { segmentFilter: '$activeFilter' })
    wiredClients({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.clients = data.map(c => ({
                ...c,
                contactUrl: '/lightning/r/Contact/' + c.contactId + '/view'
            }));
        } else if (error) {
            this.clients = [];
        }
    }

    get hasClients()    { return this.clients.length > 0; }
    get clientCount()   { return this.clients.length; }
    get totalBookAUM()  { return this.clients.reduce((sum, c) => sum + (c.totalAUM || 0), 0); }

    handleFilter(event) {
        this.activeFilter = event.target.value;
        this.isLoading    = true;
    }

    handleRowAction(event) {
        const action = event.detail.action.name;
        const row    = event.detail.row;

        if (action === 'view') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: { recordId: row.contactId, actionName: 'view' }
            });
        }
        if (action === 'logcall') {
            publish(this.messageContext, DriftAlertBroadcast, {
                contactId: row.contactId,
                driftPct:  row.driftPct
            });
        }
    }

    get allVariant()   { return this.activeFilter === 'All'         ? 'brand' : 'neutral'; }
    get driftVariant() { return this.activeFilter === 'Drift Alert' ? 'brand' : 'neutral'; }
    get riskVariant()  { return this.activeFilter === 'High Risk'   ? 'brand' : 'neutral'; }
    get churnVariant() { return this.activeFilter === 'Churn Risk'  ? 'brand' : 'neutral'; }
}
