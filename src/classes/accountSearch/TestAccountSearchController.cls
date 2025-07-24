@IsTest
public with sharing class TestAccountSearchController {
    @IsTest
    static void testSearchAccounts() {
        String name = 'Dickenson plc';
        String industry = 'Consulting';
        Integer pageSize = 100;
        Integer pageNumber = 1;
        List<Account> controllerAccounts = AccountSearchController.searchAccounts(name, industry, pageSize, pageNumber);
        Integer offset = (pageNumber - 1) * pageSize;

        String namePattern = '%' + name + '%';
        String industryPattern = '%' + industry + '%';
        List<Account> searchedAccounts = [
                SELECT Name, Industry, Phone, Type, Website
                FROM Account
                WHERE Name LIKE :namePattern AND Industry LIKE :industryPattern
                LIMIT :pageSize OFFSET :offset
        ];

        System.assertEquals(controllerAccounts.size(), searchedAccounts.size());
    }

    @IsTest
    static void countAccounts() {
        String name = 'Dickenson plc';
        String industry = 'Consulting';

        Integer controllerAccountsCount = AccountSearchController.countAccounts(name, industry);

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