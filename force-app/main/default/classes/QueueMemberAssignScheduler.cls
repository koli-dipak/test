global class QueueMemberAssignScheduler  Implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        QueueMemberAssignScheduler.assignPermissionSet();
    }
    public static void assignPermissionSet() {
        Set<Id> userIds = new Set<Id>();
        
        List<GroupMember> riskEngineeringGroupMembers = [SELECT UserOrGroupId
                                                         FROM GroupMember
                                                         WHERE Group.DeveloperName = 'Risk_Engineering_Queue'];
        
        // Extract User Ids from Group Members
        for (GroupMember groupMember : riskEngineeringGroupMembers) {
            userIds.add(groupMember.UserOrGroupId);
        }
        
        // Get the Permission Set Id
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Permission_to_RE_Team_for_Survey_Location_to_Contact' LIMIT 1].Id;
        
        // Assign the permission set to the Users (if not already assigned)
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        
        for (Id userId : userIds) {
            // Check if the permission set is already assigned
            if (!isPermissionSetAssigned(userId, permissionSetId)) {
                PermissionSetAssignment assignment = new PermissionSetAssignment();
                assignment.AssigneeId = userId;
                assignment.PermissionSetId = permissionSetId;
                assignments.add(assignment);
            }
        }
        
        // Insert the permission set assignments
        insert assignments;
        
        // Remove the permission set assignments for users not in the queue
        removePermissionSetAssignments(userIds, permissionSetId);
    }
    
    private static Boolean isPermissionSetAssigned(Id userId, Id permissionSetId) {
        // Check if the permission set is already assigned to the user
        return [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId = :permissionSetId] > 0;
    }
    
    private static void removePermissionSetAssignments(Set<Id> userIdsInQueue, Id permissionSetId) {
        // Remove permission set assignments for users not in the queue
        List<PermissionSetAssignment> assignmentsToRemove = new List<PermissionSetAssignment>();
        
        for (PermissionSetAssignment assignment : [SELECT Id, AssigneeId
                                                   FROM PermissionSetAssignment
                                                   WHERE AssigneeId NOT IN :userIdsInQueue AND PermissionSetId = :permissionSetId]) {
                                                       assignmentsToRemove.add(assignment);
                                                   }
        System.debug('assignmentsToRemove::::>'+assignmentsToRemove); 
        // Remove permission set assignments
        delete assignmentsToRemove;
        
        
        // Remove permission set assignments
        //delete assignmentsToRemove;
    }
}