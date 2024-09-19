@isTest
public class DAL_Task_T {
   @isTest
   static void getTasksByWhatId()
   {
       DAL_Task.getTasksByWhatId('');
       DAL_Task.getTasksByWhatIdsList(new List<String>{''});
    }
    
}