@isTest
public class TH_Location_T {
    public static User admin_User;
    public static Integer count = 1;
    public static String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    public static List<Schema.Location> loc = new List<Schema.Location>();

    static void proccesRecordData() {
        admin_User = TestDataFactory.createUser(true, 'Location', SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User) {
            for (Integer i = 0; i < count; i++) {
                Map<String, Object> Locationobj = new Map<String, Object>();
                Locationobj.put('Name', 'Test');
                Locationobj.put('Address_Details__c', '123 Main St');
                loc.add((Schema.Location) TestDataFactory.operationOnObjectRec('insert', 'Location', Locationobj));

				Map<String, Object> Locationobj1 = new Map<String, Object>();
                Locationobj1.put('Name', 'Test1');
                Locationobj1.put('Address_Details__c', '456 Elm St');
                loc.add((Schema.Location) TestDataFactory.operationOnObjectRec('', 'Location', Locationobj1));
            }
        }
    }
    
      static testMethod void LocationproccesRecordDataTest() 
    {
        proccesRecordData();
        Test.startTest();
        
        insert loc[1];
        update loc[1];
        Test.stopTest();
    }
}

   /* static void TestLocation(){
        admin_User = TestDataFactory.createUser(true,'Location',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User){
            for(Integer i = 0 ; i <count; i++)
            {
                Map<String,Object> Locationobj = new Map<String,Object>();
        		Locationobj.put('Name','Test');
        		Locationobj.put('Address_Details__c','123 Main St');
                Loc.add((Location) TestDataFactory.operationOnObjectRec('insert','Location', Locationobj));
            }
        }
    }*/

               /* Map<String,Object>  Accountobj = new Map<String,Object>();
                Accountobj.put('RecordTypeId',accRecordTypeId);
                Accountobj.put('Name','Hiteshm');
                Accountobj.put('Region__c','Southeast');
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
                
                Map<String,Object>  Accountobj2 = new Map<String,Object>();
                Accountobj2.put('RecordTypeId',accRecordTypeId);
                Accountobj2.put('Name','Hitesha');
                Accountobj2.put('Insured_External_Id__c','HITESHM-02');
                Accountobj2.put('Region__c','Southeast');
                acc.add((Account) TestDataFactory.operationOnObjectRec('', 'Account', Accountobj2));*/
                
            
           /* */
          // acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));