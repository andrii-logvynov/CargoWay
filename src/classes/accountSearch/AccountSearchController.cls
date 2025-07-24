public with sharing class AccountSearchController {
    private static final String QUERY_DEV_ENDPOINT = 'callout:devOrg/services/data/v62.0/query?q=';
    private static final String POST_ACCOUNT_DEV_ENDPOINT = 'callout:devOrg/services/data/v62.0/sobjects/Account/';

    @AuraEnabled(Cacheable=true)
    public static AccountResponseDto searchAccounts(String name, String industry, Integer pageSize, Integer pageNumber) {
        String namePattern = '%' + name + '%';
        String industryPattern = '%' + industry + '%';
        Integer offset = (pageNumber - 1) * pageSize;

        List<Account> accounts = [
                SELECT Name, Industry, Phone, Type, Website
                FROM Account
                WHERE Name LIKE :namePattern AND Industry LIKE :industryPattern
                ORDER BY Name
                LIMIT :pageSize OFFSET :offset
        ];

        Integer accountsCount = countInternalAccounts(name, industry);

        return new AccountResponseDto(accounts, accountsCount);
    }

    @AuraEnabled(Cacheable=false)
    public static AccountResponseDto searchAccountsFromDev(String name, String industry, Integer offset, Integer recordsPerPage){
        if(offset == null || offset < 0) {
            offset = 0;
        }
        if(recordsPerPage == null || recordsPerPage < 1) {
            recordsPerPage = 10;
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        String namePattern = '%25' + name.replaceAll(' ', '+') + '%25';
        String industryPattern = '%25' + industry.replaceAll(' ', '+') + '%25';
        String query = 'SELECT+Id,+Name,+Type,+Industry,+Phone+FROM+Account+WHERE+Name+LIKE+\'' + namePattern + '\'+AND+Industry+LIKE+\'' + industryPattern + '\'';
        String endpoint = QUERY_DEV_ENDPOINT + query;
        System.debug('Endpoint' + endpoint);

        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            AccountResponseDto result = (AccountResponseDto) JSON.deserialize(response.getBody(), AccountResponseDto.class);
            return result;
        }
        return null;
    }

    private static Integer countInternalAccounts(String name, String industry) {
        String namePattern = '%' + name + '%';
        String industryPattern = '%' + industry + '%';

        return [
                SELECT COUNT()
                FROM Account
                WHERE Name LIKE :namePattern AND Industry LIKE :industryPattern
        ];
    }
}
