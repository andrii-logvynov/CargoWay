public with sharing class AccountSearchController {
    @AuraEnabled(Cacheable=true)
    public static List<Account> searchAccounts(String name, String industry, Integer pageSize, Integer pageNumber) {
        String namePattern = '%' + name + '%';
        String industryPattern = '%' + industry + '%';
        Integer offset = (pageNumber - 1) * pageSize;

        return [
                SELECT Id, Name, Industry, Phone, Type, Website
                FROM Account
                WHERE Name LIKE :namePattern AND Industry LIKE :industryPattern
                ORDER BY Name
                LIMIT :pageSize OFFSET :offset
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static Integer countAccounts(String name, String industry) {
        String namePattern = '%' + name + '%';
        String industryPattern = '%' + industry + '%';

        return [
                SELECT COUNT()
                FROM Account
                WHERE Name LIKE :namePattern AND Industry LIKE :industryPattern
        ];
    }
}
