public class DAL_Group {

    // Function to fetch Queue Group by DeveloperName and Type
    static public Group getQueueGroupByDeveloperName(String developerName) {
        List<Group> groups = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName = :developerName LIMIT 1];
        if(groups != null && !groups.isEmpty()) {
            return groups[0];
        }
        return null; // Return null if no group found
    }
    
    public static Group getQueueGroupByName(String developerName) {
        List<Group> queueGroups = [
            SELECT Id, Name, DeveloperName, Email, Type
            FROM Group
            WHERE Type = 'Queue'
            AND DeveloperName = :developerName
        ];
        return (queueGroups.isEmpty() ? null : queueGroups[0]);
    }
    
    Static public List<Group> getriskEngineeringQueue(){
        return [Select Id, Name FROM Group WHERE Name='Risk Engineering Queue'];
    }
    
    Static public List<Group> getGroupRecordsByName(String groupName){
        return [SELECT Id, Name FROM Group WHERE Name =: groupName LIMIT 1];
    }
    
    Static public String getREQueueId(){
        return [SELECT Id, Name FROM Group WHERE Name = 'Risk Engineering Queue'].Id;
    }
    
    Static public List<Group> getGroupByOwnerId(Set<Id> ownerIds){
        return [SELECT Id, Name FROM Group WHERE Id IN :ownerIds];
    }
}