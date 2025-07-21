List<Contact> contacts = [
        SELECT Id
        FROM Contact
];

for (Contact contact : contacts) {
    contact.Description = 'Training user';
}
update contacts;