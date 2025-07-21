List<Contact> contacts = new List<Contact>();

for (Integer i = 0; i < 10001; i++) {
    contacts.add(new Contact(LastName = 'Test Contact ' + i));
}

insert contacts;