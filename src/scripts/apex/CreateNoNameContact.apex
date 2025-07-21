Contact contact = new Contact();

try {
    insert contact;
} catch (DmlException e) {
    System.debug('Cannot create Contact without Name');
}