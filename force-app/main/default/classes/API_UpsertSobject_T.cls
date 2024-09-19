@isTest	
private class API_UpsertSobject_T {


   @isTest
    public static void Test1(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/upsertSobject/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        String str = '{"Name":"AccName","attributes": {"type": "Account"}}';
        req.requestBody= Blob.valueOf(str);
        RestContext.response= res;
        API_UpsertSobject.synaticToApexMethod();
    }
@isTest
    public static void Test2(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/upsertSobject/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        String str = '{"Name":"AccName"}';
        req.requestBody= Blob.valueOf(str);
        RestContext.response= res;
        API_UpsertSobject.synaticToApexMethod();
    }
}