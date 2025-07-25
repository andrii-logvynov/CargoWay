import { LightningElement, api } from 'lwc';
import postAccount from '@salesforce/apex/AccountSearchController.postAccount';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import TYPE_FIELD from '@salesforce/schema/Account.Type';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const LOCATIONS = [
    { label: 'choose location...', value: '' },
    { label: 'Internal', value: 'Internal' },
    { label: 'External', value: 'External' },
]

const INDUSTRIES = [
    { label: 'Agriculture', value: 'Agriculture' },
    { label: 'Apparel', value: 'Apparel' },
    { label: 'Banking', value: 'Banking' },
    { label: 'Biotechnology', value: 'Biotechnology' },
    { label: 'Chemicals', value: 'Chemicals' },
    { label: 'Communications', value: 'Communications' },
    { label: 'Construction', value: 'Construction' },
    { label: 'Consulting', value: 'Consulting' },
    { label: 'Education', value: 'Education' },
    { label: 'Electronics', value: 'Electronics' },
    { label: 'Energy', value: 'Energy' },
    { label: 'Engineering', value: 'Engineering' },
    { label: 'Entertainment', value: 'Entertainment' },
    { label: 'Environmental', value: 'Environmental' },
    { label: 'Finance', value: 'Finance' },
    { label: 'Food & Beverage', value: 'Food & Beverage' },
    { label: 'Government', value: 'Government' },
    { label: 'Healthcare', value: 'Healthcare' },
    { label: 'Hospitality', value: 'Hospitality' },
    { label: 'Insurance', value: 'Insurance' },
    { label: 'Machinery', value: 'Machinery' },
    { label: 'Manufacturing', value: 'Manufacturing' },
    { label: 'Media', value: 'Media' },
    { label: 'Not For Profit', value: 'Not For Profit' },
    { label: 'Recreation', value: 'Recreation' },
    { label: 'Retail', value: 'Retail' },
    { label: 'Shipping', value: 'Shipping' },
    { label: 'Technology', value: 'Technology' },
    { label: 'Telecommunications', value: 'Telecommunications' },
    { label: 'Transportation', value: 'Transportation' },
    { label: 'Utilities', value: 'Utilities' },
    { label: 'Other', value: 'Other' }
];

const ACCOUNT_TYPES = [
    { label: 'Customer - Direct', value: 'Customer - Direct' },
    { label: 'Prospect', value: 'Prospect' },
    { label: 'Other', value: 'Other' }
];

export default class CreateAccountModal extends LightningElement {
    @api
    mode = 'create';
    @api
    record = null;

    location = '';
    locations = LOCATIONS;

    accountName = '';
    industry = '';
    industries = INDUSTRIES;

    types = ACCOUNT_TYPES;
    type = '';

    accountCreated = false;
    showAccountEditSuccess = false;

    objectApiName = 'Account';
    nameField = NAME_FIELD;
    industryField = INDUSTRY_FIELD;
    phoneField = PHONE_FIELD;
    typeField = TYPE_FIELD;

    get modalCaption() {
        return this.isCreationMode ? 'New Account' : 'Edit Account';
    }

    get isInternal() {
        return this.location === 'Internal';
    }
    get isExternal() {
        return this.location === 'External';
    }

    get isCreationMode() {
        return this.mode === 'create';
    }

    get isEditMode() {
        return this.mode === 'edit';
    }

    get recordId() {
        return this.record.Id;
    }

    handleSuccess() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account created successfully!',
                variant: 'success',
            }),
        );
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleError(event) {
        console.error('Error creating account');
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error creating record',
                message: event.detail.message,
                variant: 'error',
            }),
        );
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    onTypeChange(event) {
        this.type = event.detail.value;
    }

    accountEditSuccess() {
        this.showAccountEditSuccess = true;
    }

    createAccount(event) {
        console.log(event);

        postAccount({
            name: this.accountName,
            industry: this.industry,
            type: this.type
        }).then(response => {
            console.log('response: ', response);
            this.accountCreated = true;
        });
    }

    onNameChange(event) {
        this.accountName = event.detail.value;
    }

    onIndustryChange(event) {
        this.industry = event.detail.value;
    }

    onLocationChange(event) {
        this.location = event.detail.value;
        console.log(this.location);

    }

    onClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    onSave() {
        this.accountCreated = true;
    }
}