@IsTest
public with sharing class TestAccountSearchController {

    @IsTest
    static void testSearchAccounts() {
        String name = 'Dickenson plc';
        String industry = 'Consulting';
        Integer pageSize = 100;
        Integer pageNumber = 1;
        AccountResponseDto accountResponseDto = AccountSearchController.searchAccounts(name, industry, pageSize, pageNumber);
        Integer offset = (pageNumber - 1) * pageSize;

        String namePattern = '%' + name + '%';
        String industryPattern = '%' + industry + '%';
        List<Account> searchedAccounts = [
                SELECT Name, Industry, Phone, Type, Website
                FROM Account
                WHERE Name LIKE :namePattern AND Industry LIKE :industryPattern
                LIMIT :pageSize OFFSET :offset
        ];

        System.assertEquals(accountResponseDto.records.size(), searchedAccounts.size());
    }

    @IsTest
    static void testSearchAccountsFromDev() {
        String QUERY_DEV_ENDPOINT = 'callout:devOrg/services/data/v62.0/query?q=';
        String name = 'Dickenson plc';
        String industry = 'Consulting';
        Integer pageSize = 100;
        Integer pageNumber = 1;
        AccountResponseDto accountResponseDto = AccountSearchController.searchAccountsFromDev(name, industry, pageSize, pageNumber);
        Integer offset = (pageNumber - 1) * pageSize;

        String query = 'SELECT+Id,+Name+FROM+Account+WHERE+Name+LIKE+%25' + name + '%25+AND+Industry+LIKE+%25' + industry + '%25';
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        request.setEndpoint(QUERY_DEV_ENDPOINT + query);
        request.setMethod('POST');
        HttpResponse response = http.send(request);
        AccountResponseDto accountResponseDto2 = (AccountResponseDto) JSON.deserialize(response.getBody(), AccountResponseDto.class);
        System.assertEquals(accountResponseDto.records.size(), accountResponseDto2.records.size());
    }


    @IsTest
    static void countAccounts() {
        String name = 'Dickenson plc';
        String industry = 'Consulting';

        Integer controllerAccountsCount = AccountSearchController.searchAccounts(name, industry, 5, 1).totalSize;

        String namePattern = '%' + name + '%';
        String industryPattern = '%' + industry + '%';
        Integer accountsCount = [
                SELECT COUNT()
                FROM Account
                WHERE Name LIKE :namePattern AND Industry LIKE :industryPattern
        ];

        System.assertEquals(controllerAccountsCount, accountsCount);
    }

}