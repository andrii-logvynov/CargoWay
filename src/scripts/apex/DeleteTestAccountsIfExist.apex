List<Account> accounts = [
        SELECT Id
        FROM Account
        WHERE Name = 'Test Account'
];

delete accounts;