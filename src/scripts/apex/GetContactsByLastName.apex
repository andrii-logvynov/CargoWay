String LastName = 'Test Contact';
List<Contact> contacts = [
        SELECT Id
        FROM Contact
        WHERE LastName = :LastName
];