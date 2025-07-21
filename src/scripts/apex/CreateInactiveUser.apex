List<Profile> profiles = [
        SELECT Id
        FROM Profile
        WHERE Name = 'Standard User'
        LIMIT 1
];

Profile standardUser = profiles[0];

User user = new User(
        Username = 'TestUser@f4.com',
        LastName = 'Test',
        Email = 'andrii.logvynov@gmail.com',
        Alias = 'TestUsr',
        TimeZoneSidKey = 'Europe/Warsaw',
        LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US',
        ProfileId = standardUser.Id,
        EmailEncodingKey = 'UTF-8',
        IsActive = false
);

Database.DMLOptions dml = new Database.DMLOptions();
dml.emailHeader.triggerAutoResponseEmail = false;

user.setOptions(dml);

insert user;