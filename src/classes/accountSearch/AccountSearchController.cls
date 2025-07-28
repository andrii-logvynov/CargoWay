public with sharing class AccountSearchController {
    private static final String QUERY_DEV_ENDPOINT = 'callout:Damian_creds/services/data/v62.0/query?q=';
    private static final String POST_ACCOUNT_DEV_ENDPOINT = 'callout:Damian_creds/services/data/v62.0/sobjects/Account/';
//    private static final String QUERY_DEV_ENDPOINT = 'callout:devOrg/services/data/v62.0/query?q=';
//    private static final String POST_ACCOUNT_DEV_ENDPOINT = 'callout:devOrg/services/data/v62.0/sobjects/Account/';

    @AuraEnabled(Cacheable=false)
    public static AccountResponseDto searchAccounts(String name, String industry, Integer pageSize, Integer pageNumber) {
        System.debug('searchAccount started');
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
        System.debug('searchAccount finished');
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
    public static String postAccount(Account accountToCreate) {
        System.debug('account' + accountToCreate);
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        request.setEndpoint(POST_ACCOUNT_DEV_ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');

        Map<String, Object> account = new Map<String, Object>();
        if(accountToCreate.Name != null) account.put('Name', accountToCreate.Name);
        if(accountToCreate.Industry != null) account.put('Industry', accountToCreate.Industry);
        if(accountToCreate.Type != null) account.put('Type', accountToCreate.Type);
        if(accountToCreate.AccountNumber != null) account.put('AccountNumber', accountToCreate.AccountNumber);
        if(accountToCreate.AnnualRevenue != null) account.put('AnnualRevenue', accountToCreate.AnnualRevenue);
        if(accountToCreate.Rating != null) account.put('Rating', accountToCreate.Rating);
        if(accountToCreate.Phone != null) account.put('Phone', accountToCreate.Phone);
        if(accountToCreate.Fax != null) account.put('Fax', accountToCreate.Fax);
        if(accountToCreate.Website != null) account.put('Website', accountToCreate.Website);
        if(accountToCreate.Ownership != null) account.put('Ownership', accountToCreate.Ownership);
        if(accountToCreate.NumberOfEmployees != null) account.put('NumberOfEmployees', accountToCreate.NumberOfEmployees);


        request.setBody(JSON.serialize(account));
        HttpResponse response = http.send(request);
        return response.getStatus();
    }

    @AuraEnabled(Cacheable=false)
    public static String patchAccountToDev(Account accountToUpdate) {
        System.debug('account patch started');
        System.debug('account: ' + accountToUpdate);
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setEndpoint(POST_ACCOUNT_DEV_ENDPOINT + accountToUpdate.Id);
        request.setMethod('PATCH');
        request.setHeader('Content-Type', 'application/json');

        Map<String, Object> account = new Map<String, Object>();
        if(accountToUpdate.Name != null) account.put('Name', accountToUpdate.Name);
        if(accountToUpdate.Industry != null) account.put('Industry', accountToUpdate.Industry);
        if(accountToUpdate.Type != null) account.put('Type', accountToUpdate.Type);
        if(accountToUpdate.AccountNumber != null) account.put('AccountNumber', accountToUpdate.AccountNumber);
        if(accountToUpdate.AnnualRevenue != null) account.put('AnnualRevenue', accountToUpdate.AnnualRevenue);
        if(accountToUpdate.Rating != null) account.put('Rating', accountToUpdate.Rating);
        if(accountToUpdate.Phone != null) account.put('Phone', accountToUpdate.Phone);
        if(accountToUpdate.Fax != null) account.put('Fax', accountToUpdate.Fax);
        if(accountToUpdate.Website != null) account.put('Website', accountToUpdate.Website);
        if(accountToUpdate.Ownership != null) account.put('Ownership', accountToUpdate.Ownership);
        if(accountToUpdate.NumberOfEmployees != null) account.put('NumberOfEmployees', accountToUpdate.NumberOfEmployees);

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