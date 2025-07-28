import { LightningElement } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountSearchController.searchAccounts';
import searchAccountsFromDev from '@salesforce/apex/AccountSearchController.searchAccountsFromDev';
import { NavigationMixin } from 'lightning/navigation';

export default class AccountSearch extends NavigationMixin(LightningElement) {
    nameField = '';
    industryField = '';
    accounts = [];

    pageNumber = 1;
    totalRecords = 0;
    pageSize = 10;

    isLoading = false;
    showAccountCreation = false;
    accountCreationMode = 'create';
    record = null;

    columns = [
        {
            label: 'Name',
            fieldName: 'Name',
            type: 'button',
            initialWidth: 250,
            typeAttributes: {
                label: { fieldName: 'Name' },
                name: 'view_record',
                variant: 'base'
            },
            cellAttributes: {
                class: 'slds-text-align_left name-cell'
            }
        },
        { label: 'Industry', fieldName: 'Industry' },
        { label: 'Phone', fieldName: 'Phone' },
        { label: 'Type', fieldName: 'Type' },
        { label: 'Website', fieldName: 'Website' },
        { label: 'Location', fieldName: 'Location' },
        {
            label: 'Action',
            type: 'button',
            initialWidth: 80,
            typeAttributes: {
                label: 'Edit',
                name: 'edit'
            }
        }
    ];

    pageSizeOptions = [
        { label: '5', value: 5 },
        { label: '10', value: 10 },
        { label: '20', value: 20 },
        { label: '50', value: 50 }
    ];

    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize);
    }

    get doAccountsExist() {
        return !!this.accounts.length;
    };

    get isFirstPage() {
        return this.pageNumber === 1;
    }
    get isLastPage() {
        return this.pageNumber === this.totalPages;
    }

    connectedCallback() {
        this.fetchAccounts();
        console.log('accountSearch started');
    }

    onCloseAccountModal() {
        this.showAccountCreation = false;
        this.record = null;
    }

    onRefresh() {
        console.log('refresh...');
        this.fetchAccounts();
    }

    onCreateAccount() {
        this.accountCreationMode = 'create';
        this.showAccountCreation = true;
    }

    modifyAccount(record) {
        this.accountCreationMode = 'edit';
        this.record = record;
        this.showAccountCreation = true;
    }

    onNameFieldChange(event) {
        this.nameField = event.target.value;
    }

    onIndustryFieldChange(event) {
        this.industryField = event.target.value;
    }

    onSearch() {
        this.pageNumber = 1;
        this.fetchAccounts();
    }

    onPageSizeChange(event) {
        this.pageSize = parseInt(event.detail.value, 10);
        this.pageNumber = 1;
        this.isLoading = true;
        this.fetchAccounts();
    }

    onClearAll() {
        this.nameField = '';
        this.industryField = '';
        this.pageNumber = 1;
        this.fetchAccounts();
    }

    goToFirstPage() {
        if (this.pageNumber > 1) {
            this.pageNumber = 1;
            this.fetchAccounts();
        }
    }

    goToPreviousPage() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.fetchAccounts();
        }
    }

    goToNextPage() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber++;
            this.fetchAccounts();
        }
    }

    goToLastPage() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber = this.totalPages;
            this.fetchAccounts();
        }
    }

    fetchAccounts() {
        this.accounts = [];
        this.totalRecords = 0;
        this.isLoading = true;

        searchAccounts({
            name: this.nameField,
            industry: this.industryField,
            pageSize: this.pageSize,
            pageNumber: this.pageNumber
        }).then(response => {
            console.log('lres: ', response);
            const accounts = response.records;
            this.accounts = accounts.map(account => ({ ...account, Location: 'Internal' }));
            this.totalRecords = response.totalSize;
        }).then(() => {
            const accountsNumberToLoad = this.pageSize - this.accounts.length;
            searchAccountsFromDev({
                name: this.nameField,
                industry: this.industryField,
                pageSize: accountsNumberToLoad,
                pageNumber: this.pageNumber
            }).then(response => {
                console.log('eres: ', response);
                this.totalRecords += response.totalSize;
                if (this.accounts.length < this.pageSize) {
                    let accounts = response.records;
                    accounts = accounts.map(account => ({ ...account, Location: 'External' }));
                    this.accounts = this.accounts.concat(accounts);
                }
            }).finally(() => {
                this.isLoading = false;
            });
        });
    }

    onRowAction(event) {
        const actionName = event.detail.action.name;
        const record = event.detail.row;
        console.log('record from onrowaction: ', JSON.stringify(record));

        if (actionName === 'view_record' && record.Location === 'Internal') {
            this.navigateToRecord(record.Id);
        }

        if (actionName === 'edit') {
            this.modifyAccount(record);
        }
    }

    navigateToRecord(recordId) {
        const config = {
            type: "standard__recordPage",
            attributes: {
                recordId: recordId,
                objectApiName: "Account",
                actionName: "view"
            }
        }
        this[NavigationMixin.Navigate](config);
    }
}