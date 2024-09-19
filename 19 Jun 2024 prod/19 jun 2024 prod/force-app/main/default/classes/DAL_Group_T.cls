@isTest
public class DAL_Group_T {
    @isTest
    static void getQueueGroupByDeveloperName()
    {
        Group GP=DAL_Group.getQueueGroupByDeveloperName('Rating_Queue');
       DAL_Group.getREQueueId();
       DAL_Group.getriskEngineeringQueue();
        Group GP1=DAL_Group.getQueueGroupByName('Rating_Queue');
        Set<Id> ownerIds = new Set<Id>();
        // Call the static method from the DAL_Group class
        List<Group> groups = DAL_Group.getGroupByOwnerId(ownerIds);
        system.assertEquals(GP!=null,true);
    }
    @isTest
    static void getQueueGroupByName()
    {
        Group GP=DAL_Group.getQueueGroupByName('Rating_Queue');
        system.assertEquals(GP!=null,true);
               
    }
}