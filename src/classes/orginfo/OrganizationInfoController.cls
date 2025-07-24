public with sharing class OrganizationInfoController {
    public class LicenseInfo {
        public String name { get; set; }
        public Integer availableLicenses { get; set; }
    }

    public List<LicenseInfo> licenseInfoList { get; set; }
    public Integer numberOfApexClasses { get; set; }
    public Integer numberOfVisualforcePages { get; set; }
    public List<User> usersTable { get; set; }
    public String sessionId { get; set; }
    public String userId { get; set; }

    public OrganizationInfoController() {
        licenseInfoList = new List<LicenseInfo>();
        for(UserLicense userLicense : [
                SELECT Name, TotalLicenses, UsedLicenses
                FROM UserLicense
        ]) {
            LicenseInfo licenseInfo = new LicenseInfo();
            licenseInfo.name = userLicense.Name;
            licenseInfo.availableLicenses = userLicense.TotalLicenses - userLicense.UsedLicenses;
            licenseInfoList.add(licenseInfo);
        }

        numberOfApexClasses = [
                SELECT COUNT()
                FROM ApexClass
        ];

        numberOfVisualforcePages = [
                SELECT COUNT()
                FROM ApexPage
        ];

        usersTable = [
                SELECT Username, Email, IsActive
                FROM User
        ];

        sessionId = UserInfo.getSessionId();
    }

    public PageReference viewUser() {
        return new PageReference('/' + userId);
    }
}