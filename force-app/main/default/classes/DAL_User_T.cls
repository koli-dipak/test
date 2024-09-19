@isTest
public class DAL_User_T {
    public static User admin_User;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
	@isTest
    static void proccesRecordDataForLOB()
    {
        admin_User = TestDataFactory.createUser(true,'LOB_Management__c',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            DAL_User.getUserRecordsByUserIds(new List<String>{admin_User.Id});
        }
    
    }
    
    @isTest
    static void getUserRecordsByUserIdsSettest()
    {
        admin_User = TestDataFactory.createUser(true,'LOB_Management__c',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            DAL_User.getUserRecordsByUserIdsSet(new Set<Id>{admin_User.Id});
        }
    }
    
    @isTest
    static void getUsersByNamesteST()
    {
        admin_User = TestDataFactory.createUser(true,'LOB_Management__c',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            DAL_User.getUsersByNames(new Set<String>{admin_User.Name});
        }
    }
    
     @isTest
    static void getUsersByNamesListTest()
    {
        admin_User = TestDataFactory.createUser(true,'LOB_Management__c',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            DAL_User.getUsersByNamesList(new List<String>{admin_User.Name});
            DAL_User.getUsersByIds(new Set<Id>{admin_User.Id});
            DAL_User.getUsersByIds(new Set<String>{admin_User.Id});
            DAL_User.getNotifyingUsers(admin_User.Id);
            DAL_User.getUsersByName(new set<String>{admin_User.Name});
            DAL_User.getCreatedByUser(admin_User.Id);
            DAL_User.getUsersByOwnerId(new Set<Id>{admin_User.Id});
            DAL_User.getUsersOfREQueue();
            DAL_User.getUsersByName(new List<String> {'Test@gmail.com'});
        }
    
    }
    
}