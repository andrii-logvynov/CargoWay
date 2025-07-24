public with sharing class AccountSearchController {
    private static final String QUERY_DEV_ENDPOINT = 'callout:devOrg/services/data/v62.0/query?q=';
    private static final String POST_ACCOUNT_DEV_ENDPOINT = 'callout:devOrg/services/data/v62.0/sobjects/Account/';

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

    @AuraEnabled(Cacheable=false)
    public static List<Account> searchAccountsFromDev(String name, String industry, Integer offset, Integer recordsPerPage){
        if(offset == null || offset < 0) {
            offset = 0;
        }
        if(recordsPerPage == null || recordsPerPage < 1) {
            recordsPerPage = 10;
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Map<String,String> fieldToValueMap = new Map<String,String>{
                'Name' => name,
                'Industry' => industry
        };

        String namePattern = '%25' + name.replaceAll(' ', '+') + '%25';
        String industryPattern = '%25' + industry.replaceAll(' ', '+') + '%25';
        String query = 'SELECT+Id,+Name,+Type,+Industry,+Phone+FROM+Account+WHERE+Name+LIKE+\'' + namePattern + '\'+AND+Industry+LIKE+\'' + industryPattern + '\'';
        String endpoint = QUERY_DEV_ENDPOINT + query;
        System.debug('Endpoint' + endpoint);

        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        List<Account> accounts = new List<Account>();
        if(response.getStatusCode() == 200) {
            AccountResponseWrapper result = (AccountResponseWrapper) JSON.deserialize(response.getBody(), AccountResponseWrapper.class);
            return result.records != null ? result.records : new List<Account>();
        }
        return accounts;
    }

    private class AccountResponseWrapper {
        public List<Account> records;
    }

}
