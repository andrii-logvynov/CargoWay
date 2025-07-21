for (Contact contact : [
        SELECT Phone
        FROM Contact
]) {
    if (String.isEmpty(contact.Phone)) {
        System.debug('Contact with Id: ' + contact.Id + ' does not have a Phone');
    }
}