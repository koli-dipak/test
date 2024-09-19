@isTest
public class DAL_EmailTemplate_T {
   @isTest
   static void getTemplateExist()
   {
        EmailTemplate EM=DAL_EmailTemplate.getTaskEmailTemplate('Task_Notification_of_Checklist_to_UWA_and_UW');
        system.assertEquals(EM!=null,true);
    }
    @isTest
    static void getTemplateNotExist()
    {
         EmailTemplate EM=DAL_EmailTemplate.getTaskEmailTemplate('Task_Notification_of_Checklist_to_UWA_and_UW1');
        system.assertEquals(EM==null,true);
               
    }
}