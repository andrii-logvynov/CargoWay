import { LightningElement, api } from 'lwc';
import postAccount from '@salesforce/apex/AccountSearchController.postAccount';
import patchAccountToDev from '@salesforce/apex/AccountSearchController.patchAccountToDev';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";

const LOCATIONS = [
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

const RATING_OPTIONS = [
    { label: 'Hot', value: 'Hot' },
    { label: 'Warm', value: 'Warm' },
    { label: 'Cold', value: 'Cold' },
]

const OWNERSHIP_OPTIONS = [
    { label: 'Public', value: 'Public' },
    { label: 'Private', value: 'Private' },
    { label: 'Subsidiary', value: 'Subsidiary' },
    { label: 'Other', value: 'Other' },
];

export default class CreateAccountModal extends NavigationMixin(LightningElement) {
    @api
    mode = 'create';

    picklists = {
        locations: LOCATIONS,
        industries: INDUSTRIES,
        types: ACCOUNT_TYPES,
        ratingOptions: RATING_OPTIONS,
        ownershipOptions: OWNERSHIP_OPTIONS
    }

    _accountData = {};

    _isInternal = true;
    isLoading = false;

    get accountLocation() {
        return this._isInternal ? 'Internal' : 'External';
    }

    @api
    get account() {
        return this._accountData;
    }

    set account(value) {
        this._accountData = { ...value};
    }

    get modalCaption() {
        return this.isCreationMode ? 'New Account' : 'Edit Account';
    }

    get isInternal() {
        if (this.account.Id) {
            return this.account.Location === 'Internal';
        } else {
            return this._isInternal;
        }
    }
    get isExternal() {
        if (this.account?.Id) {
            return this.account.Location === 'External';
        } else {
            return !this._isInternal;
        }
    }

    get isCreationMode() {
        return this.mode === 'create';
    }

    get isEditMode() {
        return this.mode === 'edit';
    }

    get accountIdOrNull() {
        return this.account.Id || null;
    }

    onSuccess() {
        this.showToast('Success', `Account ${this.isCreationMode ? 'created' : 'updated'} successfully!`, 'success');
        this.dispatchEvent(new CustomEvent('refresh', {bubbles: true}));
        this.onClose();
    }

    onError() {
        this.showToast('Error creating Account', 'Account creation failed', 'error');
    }

    onFieldChange(event) {
        const field = event.target.dataset.field;
        const value = event.detail.value;
        this._accountData = {
            ...this.account,
            [field]: value
        }
    }

    onLocationChange(event) {
        if (event.detail.value === 'Internal') {
            const config = {
                type: "standard__recordPage",
                attributes: {
                    recordId: this.account.Id,
                    objectApiName: "Account",
                    actionName: "edit"
                }
            };
            this[NavigationMixin.Navigate](config);
        } else {
            this._isInternal = false;
        }
    }

    onClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    onSave() {
        this.isLoading = true;
        if (this.isCreationMode) {

            console.log('account', JSON.stringify(this.account));
            postAccount({ accountToCreate: this.account }).then(_response => {
                this.onSuccess();
                this.isLoading = false;
            });
        } else {
            delete this.account.Location;
            const attributes = this.account.attributes;
            delete this.account.attributes;

            this._accountData = { ...this.account, ...attributes };
            console.log('account', JSON.stringify(this.account));

            patchAccountToDev({ accountToUpdate: this.account }).then(_response => {
                this.onSuccess();
                this.isLoading = false;
            });
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}