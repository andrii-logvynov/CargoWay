Account account = [
        SELECT Id
        FROM Account
        WHERE Name = 'Test Account'
];
account.Name = 'Updated Account';

update account;