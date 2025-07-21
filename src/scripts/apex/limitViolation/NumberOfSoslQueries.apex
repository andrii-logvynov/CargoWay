for (Integer i = 0; i < 21; i++) {
    List<List<Contact>> contacts = [
            FIND 'Test'
            IN ALL FIELDS
            RETURNING Contact(Id)
    ];
}