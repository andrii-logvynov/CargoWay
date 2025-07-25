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
    recordId = '';
    record = null;

    columns = [
        {
            label: 'Name',
            fieldName: 'Name',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'Name' },
                name: 'view_record'
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

    onCloseAccountModal() {
        this.showAccountCreation = false;
    }

    connectedCallback() {
        this.fetchAccounts();
    }

    onCreateAccount() {
        this.accountCreationMode = 'create';
        this.showAccountCreation = true;
    }

    modifyAccount(recordId) {
        this.accountCreationMode = 'edit';
        this.recordId = recordId;
        this.showAccountCreation = true;

    }

    handleNameFieldChange(event) {
        this.nameField = event.target.value;
    }

    handleIndustryFieldChange(event) {
        this.industryField = event.target.value;
    }

    search() {
        this.pageNumber = 1;
        this.fetchAccounts();
    }

    handlePageSizeChange(event) {
        this.pageSize = parseInt(event.detail.value, 10);
        this.pageNumber = 1;
        this.isLoading = true;
        this.fetchAccounts();
    }

    clearAll() {
        this.nameField = '';
        this.industryField = '';
        this.pageNumber = 1;
        this.fetchAccounts();
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

    onRowAction(event) {
        console.log('rowaction event: ', event);
        console.log('detail: ', event.detail);
        console.log('detail.action: ', event.detail.action);
        console.log('detail.row: ', event.detail.row);
        console.log('detail.row.Id: ', event.detail.row.Id);
        const actionName = event.detail.action.name;
        console.log('actionName: ', actionName);
        const row = event.detail.row;
        this.recordId = row.Id;
        this.record = row;

        if (actionName === 'view_record' && row.Location === 'Local') {
            console.log('navigation...');
            this.navigateToRecord(this.recordId);
        }

        if (actionName === 'edit') {
            this.modifyAccount(this.recordId);
        }
    }

    navigateToRecord(event) {
        this.recordId = event.detail.row.Id;
        console.log(this.recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
}
