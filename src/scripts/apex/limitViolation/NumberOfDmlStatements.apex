List<Contact> contacts = [
        SELECT LastName
        FROM Contact
        WHERE LastName = 'Test Contact 0'
];
Contact contact;
if (!contacts.isEmpty()) {
    contact = contacts[0];
}

for (Integer i = 0; i < 151; i++) {
    contact.LastName = 'Test Contact ' + i;
    update contact;
}
contact.LastName = 'Test Contact 0';