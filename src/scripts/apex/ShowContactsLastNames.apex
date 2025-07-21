for (Contact contact : [
        SELECT LastName
        FROM Contact
]) {
    System.debug(contact.LastName);
}