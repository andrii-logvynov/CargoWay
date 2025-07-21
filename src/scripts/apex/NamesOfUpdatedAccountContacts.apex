List<Account> accounts = [
        SELECT (
                SELECT Name
                FROM Contacts
        )
        FROM Account
        WHERE Name = 'Updated Account'
];

for (Account account : accounts) {
    for (Contact contact : account.Contacts) {
        System.debug(contact.Name);
    }
}
