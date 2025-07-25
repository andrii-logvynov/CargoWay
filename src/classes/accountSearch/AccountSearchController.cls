public with sharing class AccountSearchController {
    private static final String QUERY_DEV_ENDPOINT = 'callout:Damian_creds/services/data/v62.0/query?q=';
    private static final String POST_ACCOUNT_DEV_ENDPOINT = 'callout:Damian_creds/services/data/v62.0/sobjects/Account/';
//    private static final String QUERY_DEV_ENDPOINT = 'callout:devOrg/services/data/v62.0/query?q=';
//    private static final String POST_ACCOUNT_DEV_ENDPOINT = 'callout:devOrg/services/data/v62.0/sobjects/Account/';

    @AuraEnabled(Cacheable=true)
    public static AccountResponseDto searchAccounts(String name, String industry, Integer pageSize, Integer pageNumber) {
        System.debug('Method started');
        String namePattern = '%' + name + '%';
        String industryPattern = '%' + industry + '%';
        Integer offset = (pageNumber - 1) * pageSize;

        String query = 'SELECT Name, Industry, Phone, Type, Website FROM Account WHERE Name LIKE :namePattern';

        if (industry != null && industry != '') {
            query += ' AND Industry LIKE :industryPattern';
        }
        query += ' ORDER BY Name LIMIT :pageSize OFFSET :offset';

        List<Account> accounts = Database.query(query);

        Integer accountsCount = countInternalAccounts(name, industry);
        System.debug('Method end');
        AccountResponseDto responseDto = new AccountResponseDto(accounts, accountsCount);
        System.debug(responseDto);
        return responseDto;
    }

    @AuraEnabled(Cacheable=false)
    public static AccountResponseDto searchAccountsFromDev(String name, String industry, Integer offset, Integer recordsPerPage) {
        if (offset == null || offset < 0) {
            offset = 0;
        }
        if (recordsPerPage == null || recordsPerPage < 1) {
            recordsPerPage = 10;
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        String namePattern = '%25' + name.replaceAll(' ', '+') + '%25';
        String industryPattern = '%25' + industry.replaceAll(' ', '+') + '%25';
        String query = 'SELECT+Id,+Name,+Type,+Industry,+Phone+FROM+Account+WHERE+Name+LIKE+\'' + namePattern + '\'';
        if (industry != '') {
            query += '+AND+Industry+LIKE+\'' + industryPattern + '\'';
        }
        query += '+LIMIT+' + recordsPerPage + '+OFFSET+' + offset;
        String endpoint = QUERY_DEV_ENDPOINT + query;
        System.debug('Endpoint' + endpoint);

        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            AccountResponseDto result = (AccountResponseDto) JSON.deserialize(response.getBody(), AccountResponseDto.class);
            return result;
        }
        return null;
    }

    @AuraEnabled(Cacheable=false)
    public static String postAccount(String name, String industry, String type) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        request.setEndpoint(POST_ACCOUNT_DEV_ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        Map<String, Object> account = new Map<String, Object>{
                'Name' => name,
                'Industry' => industry,
                'Type' => type
        };
        request.setBody(JSON.serialize(account));
        HttpResponse response = http.send(request);
        return response.getStatus();
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
