@isTest
private class QueueMemberAssignScheduler_T {
    public static Integer count = 1;
    public static List<GroupMember> groupmem = new List<GroupMember>();
    
    @isTest
    static void testAssignPermissionSet() {
        String ADMIN_PROFILE = 'System Administrator';
        User admin_User = TestDataFactory.createUser(true,'Case',ADMIN_PROFILE);
        insert admin_User; 
        List<Group> GroupName = [SELECT Id FROM Group WHERE DeveloperName = 'Risk_Engineering_Queue'];
        
        Map<String,Object>  testGroupMember = new Map<String,Object>();
        testGroupMember.put('UserOrGroupId',admin_User.Id);
        testGroupMember.put('GroupId',GroupName[0].Id);
        
        for(Integer i = 0 ; i <count; i++)
        {
            groupmem.add((GroupMember) TestDataFactory.operationOnObjectRec('insert', 'GroupMember', testGroupMember));
        }
        Test.startTest();
        QueueMemberAssignScheduler qma = new QueueMemberAssignScheduler();
        qma.execute(null);
        Test.stopTest();
        
    }
    
    @isTest
    static void testAssignPermissionSet2() {
        
        String ADMIN_PROFILE = 'System Administrator';
        User admin_User = TestDataFactory.createUser(true,'Case',ADMIN_PROFILE);
        insert admin_User; 
        // Get the Permission Set Id
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Permission_to_RE_Team_for_Survey_Location_to_Contact' LIMIT 1].Id;
        
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignment = new PermissionSetAssignment();
        assignment.AssigneeId = admin_User.Id;
        assignment.PermissionSetId = permissionSetId;
        assignments.add(assignment);
        insert assignments;
        Test.startTest();
        QueueMemberAssignScheduler qma = new QueueMemberAssignScheduler();
        qma.execute(null);
        Test.stopTest();
    }
}