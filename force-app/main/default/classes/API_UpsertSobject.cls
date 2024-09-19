@RestResource(urlMapping='/upsertSobject/*')
global class API_UpsertSobject {
    @HttpPost
    global static Map<String,String> synaticToApexMethod(){
        Map<String,String> returnMap=new Map<String,String>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        System.debug('@@req_new.requestBody::'+ req.requestBody.toString());
        String reqBody=req.requestBody.toString();
        
        try
        {
            SObject customObject = (SObject)JSON.deserialize(reqBody, Sobject.class);
            upsert customObject;
            returnMap.put('sf__Id',customObject.Id);
            returnMap.put('id',customObject.Id);
            return returnMap;
        }
        catch(Exception ex)
        {
            System.debug(' @@@@@ Don\'t visible '+ex.getMessage());
        }
        return null;
    }
}