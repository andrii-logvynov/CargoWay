@IsTest
private class AccountSearchControllerTest {

    @TestSetup
    static void makeData(){
        List<Account> accountsToInsert = new List<Account>();
        for(Integer i=0; i<15; i++){
            accountsToInsert.add(new Account(
                    Name = 'Test Account ' + i,
                    Industry = (i < 10 ? 'Technology' : 'Banking'), // First 10 are Tech, next 5 are Banking
                    Phone = '12345678' + i,
                    Type = 'Prospect'
            ));
        }
        insert accountsToInsert;
    }

    @IsTest
    static void testSearchAccounts_WithNameAndIndustry() {
        Test.startTest();
        AccountResponseDto result = AccountSearchController.searchAccounts('Test', 'Technology', 5, 1);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals(5, result.records.size(), 'Should return 5 records for the first page');
        System.assertEquals(10, result.totalSize, 'Total count of Technology accounts should be 10');
    }

    @IsTest
    static void testSearchAccounts_WithNameOnly() {
        Test.startTest();
        AccountResponseDto result = AccountSearchController.searchAccounts('Test', '', 10, 1);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals(10, result.records.size(), 'Should return 10 records for the first page');
        System.assertEquals(15, result.totalSize, 'Total count of all test accounts should be 15');
    }

    @IsTest
    static void testSearchAccounts_Pagination() {
        Test.startTest();
        AccountResponseDto result = AccountSearchController.searchAccounts('Test', 'Technology', 5, 2);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals(5, result.records.size(), 'Should return 5 records for the second page');
        System.assertEquals(10, result.totalSize, 'Total count of Technology accounts should still be 10');
    }

    @IsTest
    static void testSearchAccountsFromDev_Success() {
        Test.setMock(HttpCalloutMock.class, new AccountSearchMock(200, 'OK', '{"totalSize": 1, "records": [{"Name": "External Account"}]}'));

        Test.startTest();
        AccountResponseDto result = AccountSearchController.searchAccountsFromDev('External', 'Energy', 0, 10);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Response from dev org should not be null');
        System.assertEquals(1, result.totalSize, 'Mock total size should be 1');
        System.assertEquals('External Account', result.records[0].Name, 'Account name should match mock data');
    }

    @IsTest
    static void testSearchAccountsFromDev_Error() {
        Test.setMock(HttpCalloutMock.class, new AccountSearchMock(500, 'Server Error', ''));

        Test.startTest();
        AccountResponseDto result = AccountSearchController.searchAccountsFromDev('Error', '', 0, 10);
        Test.stopTest();

        System.assertEquals(null, result, 'Result should be null on server error');
    }

    @IsTest
    static void testPostAccount_Success() {
        Test.setMock(HttpCalloutMock.class, new AccountSearchMock(201, 'Created', ''));

        Account accountToCreate = new Account(Name='New External Co', Industry='Retail', Type='Customer - Direct');

        Test.startTest();
        String status = AccountSearchController.postAccount(accountToCreate);
        Test.stopTest();

        System.assertEquals('Created', status, 'Status should be "Created" on successful post');
    }

    @IsTest
    static void testPatchAccountToDev_Success() {
        Test.setMock(HttpCalloutMock.class, new AccountSearchMock(204, 'No Content', ''));

        Account accountToUpdate = new Account(Id='001xx000003Gii3AAC', Name='Updated Name');

        Test.startTest();
        String status = AccountSearchController.patchAccountToDev(accountToUpdate);
        Test.stopTest();

        System.assertEquals('No Content', status, 'Status should be "No Content" on successful patch');
    }

    private class AccountSearchMock implements HttpCalloutMock {
        protected Integer statusCode;
        protected String status;
        protected String body;

        public AccountSearchMock(Integer statusCode, String status, String body) {
            this.statusCode = statusCode;
            this.status = status;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setStatus(this.status);
            res.setBody(this.body);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
}
