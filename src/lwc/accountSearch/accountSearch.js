import { LightningElement, track } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountSearchController.searchAccounts';
import countAccounts from '@salesforce/apex/AccountSearchController.countAccounts';

export default class AccountSearch extends LightningElement {
    @track nameField = '';
    @track industryField = '';
    @track accounts = [];
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track pageSize = 10;
    isLoading = false;

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Industry', fieldName: 'Industry' },
        { label: 'Phone', fieldName: 'Phone' },
        { label: 'Type', fieldName: 'Type' },
        { label: 'Website', fieldName: 'Website' }
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

    connectedCallback() {
        this.fetchAccounts();
    }

    handleSearch1(event) {
        this.nameField = event.target.value;
        this.pageNumber = 1;
        this.fetchAccounts();
    }

    handleSearch2(event) {
        this.industryField = event.target.value;
        this.pageNumber = 1;
        this.fetchAccounts();
    }

    handlePageSizeChange(event) {
        this.pageSize = parseInt(event.detail.value, 10);
        this.pageNumber = 1;
        this.fetchAccounts();
    }

    clearAll() {
        this.nameField = '';
        this.industryField = '';
        this.pageNumber = 1;
        this.fetchAccounts();
    }

    fetchAccounts() {
        this.isLoading = true;

        countAccounts({ name: this.nameField, industry: this.industryField })
            .then(result => {
                this.totalRecords = result;
                this.isLoading = false;
            });

        searchAccounts({
            name: this.nameField,
            industry: this.industryField,
            pageSize: this.pageSize,
            pageNumber: this.pageNumber
        }).then(result => {
            this.accounts = result;
            this.isLoading = false;
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
}
