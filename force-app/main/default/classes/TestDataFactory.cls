public class TestDataFactory {
    
    private static final Integer DEFAULT_NAME_LEN = 15;
    private static final String ADMIN_PROFILE = 'System Administrator';
    public Static SObject operationOnObjectRecord(String ActionString,String sObjectName,Map <String,Object> MapFieldsAndValue)
    {
        //get the object describe
        Schema.SObjectType oSObjectType=Schema.getGlobalDescribe().get(sObjectName);
        //Create the instance of the object
        Sobject oObject = oSObjectType.newSObject();
        
        //Set dummy data for the rest of the fields in the object
        for (Schema.SObjectField oFieldSet: oSObjectType.getDescribe().fields.getMap().values())
        {
            Schema.DescribeFieldResult oDescribeFieldResult=oFieldSet.getDescribe();
            System.debug('@@oDescribeFieldResult ::'+oDescribeFieldResult);
            if (oDescribeFieldResult.isCreateable() 
                && (MapFieldsAndValue==Null || MapFieldsAndValue.isEmpty() 
                    || !MapFieldsAndValue.containsKey(oDescribeFieldResult.getName())))
            {
                if(String.ValueOf(oDescribeFieldResult.getType())=='STRING')
                {
                    Integer Length=oDescribeFieldResult.getLength();
                    if (Length >= 10)
                    {
                        Length=10;
                    }
                    oObject.put(oDescribeFieldResult.getName(),generateRandomString(Length));
                }
                else if (String.ValueOf(oDescribeFieldResult.getType())=='BOOLEAN')
                {
                    oObject.put(oDescribeFieldResult.getName(),getRandomBoolean());
                }
                else if(String.ValueOf(oDescribeFieldResult.getType())=='DATETIME')
                {
                    oObject.put(oDescribeFieldResult.getName(),System.Now());
                }
                else if (String.ValueOf(oDescribeFieldResult.getType())=='DATE')
                {
                    oObject.put(oDescribeFieldResult.getName(),System.Today()+generaterandomInteger(2));
                }
                else if (String.ValueOf(oDescribeFieldResult.getType())=='DOUBLE')
                {
                    oObject.put(oDescribeFieldResult.getName(),Double.ValueOf(generaterandomInteger(oDescribeFieldResult.getDigits())));
                }
                else if (String.ValueOf(oDescribeFieldResult.getType())=='EMAIL')
                {
                    oObject.put(oDescribeFieldResult.getName(),generateRandomEmail());
                }
                
            }
        }
        
        //Set the values of the fields according to the map
        if (MapFieldsAndValue!=null && !MapFieldsAndValue.isEmpty())
        {
            system.debug('@@keysString: '+MapFieldsAndValue.keySet());
            for(String keysString:MapFieldsAndValue.keySet())
            {
                system.debug('@@aa: '+MapFieldsAndValue.get(keysString));
                oObject.put(keysString,MapFieldsAndValue.get(keysString));
            }
        }
        
        if (ActionString!=Null && ActionString!='')
        {
            if (ActionString.toLowerCase()=='insert')
            {
                insert oObject;
            }
            else if (ActionString.toLowerCase()=='update')
            {
                update oObject;
            }
            else if (ActionString.toLowerCase()=='upsert')
            {
                upsert oObject;
            }
            else if (ActionString.toLowerCase()=='delete')
            {
                delete oObject;
            }
        }
        return oObject;
    }
    
    public Static SObject operationOnObjectRec(String ActionString,String sObjectName,Map <String,Object> MapFieldsAndValue)
    {
        //get the object describe
        Schema.SObjectType oSObjectType=Schema.getGlobalDescribe().get(sObjectName);
        //Create the instance of the object
        Sobject oObject = oSObjectType.newSObject();
        
        //Set the values of the fields according to the map
        if (MapFieldsAndValue!=null && !MapFieldsAndValue.isEmpty())
        {
            system.debug('@@keysString: '+MapFieldsAndValue.keySet());
            for(String keysString:MapFieldsAndValue.keySet())
            {
                system.debug('@@aa: '+MapFieldsAndValue.get(keysString));
                oObject.put(keysString,MapFieldsAndValue.get(keysString));
            }
        }
        
        if (ActionString!=Null && ActionString!='')
        {
            if (ActionString.toLowerCase()=='insert')
            {
                insert oObject;
            }
            else if (ActionString.toLowerCase()=='update')
            {
                update oObject;
            }
            else if (ActionString.toLowerCase()=='upsert')
            {
                upsert oObject;
            }
            else if (ActionString.toLowerCase()=='delete')
            {
                delete oObject;
            }
        }
        return oObject;
    }
    
    public static String generateRandomString(Integer len) 
    {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    //This method is used to generate a random integer
    public Static Integer generaterandomInteger(Integer upperLimit){
        Integer rand = Math.round(Math.random()*1000);
        if (upperLimit==0)
        {
            return 0;
        }
        return Math.mod(rand, upperLimit);
    }
    //This method is used to create a user
    public Static User createUser(Boolean ifinsert,  Boolean bypassValidationRule,String bypassTrigger)
    {
        //UserRole r = new UserRole(DeveloperName = 'testUserRole'+System.currentTimeMillis(), Name = generateRandomString(5));
        //insert r;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = generateRandomEmail(),
            Username = generateRandomEmail() + System.currentTimeMillis(),
            CompanyName = generateRandomString(3),
            Title = generateRandomString(3),
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ByPassValidation__c = bypassValidationRule
            //UserRoleId = r.Id,
        );
        if (ifinsert)
        {
            insert u;
        }
        return u;
    }
    
    
    
    //This method is used to generate an email id
    public Static String generateRandomEmail()
    {
        String emailString=generateRandomString(6)+'@'+generateRandomString(6)+'.com';
        return emailString;
    }
    
    private static final IntegerRange BINARY_RANGE = new IntegerRange(0,1);
    
    public static Boolean getRandomBoolean(){
        return nextInteger(BINARY_RANGE,true) == 1;
    }
    
    public static Integer nextInteger(IntegerRange range, Boolean inclusive){
        if(range == null){
            return null;
        }
        if(inclusive && (range.max() - range.min()) <= 0){
            return range.min();
        }
        if(!inclusive && (range.max() - range.min()) <= 2){
            return range.min();
        }
        Integer inclusiveChange1 = -1;
        if(inclusive) inclusiveChange1 = 1;
        Integer inclusiveChange2 = 1;
        if(inclusive) inclusiveChange2 = 0;
        return (Integer) (
            Math.round(
                Math.floor(
                    Math.random()
                    * ((range.max()-range.min()+inclusiveChange1))
                )
            ) 
            + range.min()
            + inclusiveChange2
        );
    }
    
    public class IntegerRange {
        
        private Integer min;
        private Integer max;
        
        public IntegerRange(Integer number1){
            if(number1 == null){
                throw new IllegalArgumentException('illegal argument: null number');
            }
            min = max = number1;
        } 
        public IntegerRange(Integer number1, Integer number2){
            if(number1 == null || number2 == null){
                throw new IllegalArgumentException('illegal argument: null number');
            }
            if(number1 < number2){
                min = number1;
                max = number2;    
            } else {
                min = number2;
                max = number1;    
            }
        }
        
        public Integer max(){ return max; }
        public Integer min(){ return min;}
        public String toAString(){ return '[' + min + ',' + max + ']'; }
        public Boolean contains(Integer value){ return min <= value && value <= max; }
        public Boolean contains(IntegerRange value){ return min <= value.min() && value.max() <= max; }
        public Boolean overlaps(IntegerRange value){ return min <= value.max() && value.min() <= max; }
        
    }
    
    public static User createUser(boolean bypassValidation,
                                  String byPassSelectedTrigger,
                                  String profileName) {
                                      User Admin_User;
                                      
                                      Map<String, Id> profileMap = new Map<String, Id>();
                                      
                                      for(Profile p : [SELECT Id, Name From Profile]) 
                                      {
                                          profileMap.put(p.Name, p.Id);
                                      }
                                      
                                      Admin_User = new User(
                                          Username = generateRandomEmail() + System.currentTimeMillis()//'adminA2@admin.com'
                                          , ProfileId = profileMap.get(profileName)
                                          , Alias = 'test123'
                                          , Email = generateRandomEmail()//'admin@admin.com'
                                          , EmailEncodingKey = 'UTF-8'
                                          , LastName = 'TestAdmin'
                                          , TimeZoneSidKey = 'Europe/Berlin'
                                          , LocaleSidKey = 'en_US'
                                          , LanguageLocaleKey = 'en_US'
                                          , ByPassValidation__c = bypassValidation
                                          ,ByPassTrigger__c = byPassSelectedTrigger
                                          
                                      );
                                      
                                      return Admin_User;
                                  }
    
    public class IllegalArgumentException extends Exception {}
    
}