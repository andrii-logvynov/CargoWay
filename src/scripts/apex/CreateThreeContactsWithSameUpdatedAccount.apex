List<Account> accounts = [
        SELECT Id
        FROM Account
        WHERE Name = 'Updated Account'
];

if (!accounts.isEmpty()) {
        Account account = accounts[0];
        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < 3; i++) {
                Contact contact = new Contact(FirstName = 'Test Contact ' + i, LastName = 'Test', AccountId = account.Id);
                contacts.add(contact);
        }

        insert contacts;
}
