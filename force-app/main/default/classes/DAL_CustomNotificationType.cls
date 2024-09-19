public class DAL_CustomNotificationType {
    
    public static CustomNotificationType getCustomNotificationType(String developerName) {
        List<CustomNotificationType> notificationTypes = [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = :developerName
        ];
        
        return (notificationTypes.isEmpty() ? null : notificationTypes[0]);
    }
    
    
}