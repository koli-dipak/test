public class DAL_User {
    // Function to fetch User records by a list of User IDs
    public Static List<User> getUserRecordsByUserIds(List<String> UserIds){
        return [SELECT Id, Name,Email FROM User WHERE Id IN :UserIds];
    }
    // Function to fetch User records by a set of User IDs
    public Static List<User> getUserRecordsByUserIdsSet(Set<Id> userIds){
        return [SELECT Id, Name,Email FROM User WHERE Id IN :UserIds];
    }
    // Function to fetch User records by a set of unique User Names
    public static List<User> getUsersByNames(Set<String> uniqueUserNames) {
        return [
            SELECT Id, Name
            FROM User
            WHERE Name IN :uniqueUserNames
        ];
    }
    // Function to fetch User records by a list of User Names
    public static List<User> getUsersByNamesList(List<String> userNames) {
        return [
            SELECT Id, Name
            FROM User
            WHERE Name IN :userNames
        ];
    }
    // Function to fetch a map of User records by a set of User IDs (String type)
    public static Map<Id, User> getUsersByIds(Set<String> userIds) {
        Set<Id> userIdsSet = new Set<Id>();
        for (String userIdString : userIds) {
            userIdsSet.add(userIdString);
        }

        return new Map<Id, User>([
            SELECT Id, Name, Email, Underwriting_Associate__r.Name, Underwriting_Associate__r.Email, Underwriting_Associate__c
            FROM User
            WHERE Id IN :userIdsSet
            LIMIT 50000
        ]);
    }
    // Function to fetch a map of User records by a set of User IDs (Id type)
    public static Map<Id, User> getUsersByIds(Set<Id> userIds) {
        return new Map<Id, User>([
            SELECT Id, Name, Email, Underwriting_Associate__r.Name, Underwriting_Associate__r.Email, Underwriting_Associate__c
            FROM User
            WHERE Id IN :userIds
            LIMIT 50000
        ]);
    }
    // Function to fetch a single User record by notifying User ID
    public static List<User> getNotifyingUsers(Id notifyingUserId) {
        try {
            return [
                SELECT Id, Name, Email, Underwriting_Associate__r.Name, Underwriting_Associate__c
                FROM User
                WHERE Id = :notifyingUserId
                LIMIT 1
            ];
        } catch (QueryException e) {
            // Handle the exception as needed
            return new List<User>();
        }
    }
    // Function to fetch User records by a set of Underwriter Names
    public static List<User> getUsersByName(Set<String> underwriterNames) {
        return [
            SELECT Id, Email, Name
            FROM User
            WHERE Name IN :underwriterNames
        ];
    }
    // Function to fetch Users of the 'Risk Engineering Queue' group
    public static List<User> getUsersOfREQueue() {
        return [SELECT Id, Name, Email
                FROM User
                WHERE Id IN (SELECT UserOrGroupId
                             FROM GroupMember
                             WHERE Group.Name = 'Risk Engineering Queue')];
    }
    // Function to fetch the User record by Created By User ID
    public static User getCreatedByUser(Id createdByIdDetails) {
        return [SELECT Email, Name FROM User WHERE Id =: createdByIdDetails LIMIT 1];
    }
    // Function to fetch User records by Owner IDs
    public static List<User> getUsersByOwnerId(Set<Id> ownerIds) {
        return [SELECT Id, Name, Email FROM User WHERE Id IN :ownerIds];
    }
    //Function to fetch the User Record by their Name
    public static List<User> getUsersByName(List<String> userEmail) {
        return [SELECT Id,Name,Department,Email from User where Email IN: userEmail];
    }
}