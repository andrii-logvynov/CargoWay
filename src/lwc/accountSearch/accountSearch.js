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

    columns = [
        {
            label: 'Name', fieldName: 'Name', type: 'url',
            typeAttributes: {
                label: { fieldName: 'Name' },
                name: 'view_record'
            }
        },
        { label: 'Industry', fieldName: 'Industry' },
        { label: 'Phone', fieldName: 'Phone' },
        { label: 'Type', fieldName: 'Type' },
        { label: 'Website', fieldName: 'Website' },
        { label: 'Location', fieldName: 'Location' }
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

    connectedCallback() {
        this.fetchAccounts();
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
        }).then(accounts => {
            this.accounts = accounts.map(account => ({ ...account, Location: 'Internal' }));
        }).then(() => {
            searchAccountsFromDev({
                name: this.nameField,
                industry: this.industryField,
                pageSize: this.pageSize,
                pageNumber: this.pageNumber
            })
                .then(accounts => {
                    this.totalRecords = this.accounts.length + accounts.length;
                    if (this.accounts.length < this.pageSize) {
                        accounts = accounts.map(account => ({ ...account, Location: 'External' }));
                        this.accounts = this.accounts.concat(accounts);
                    }
                    this.isLoading = false;
                })
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

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'view_record' && row.OrgType === 'Local') {
            this.navigateToRecord(row.Id);
        }
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
}
