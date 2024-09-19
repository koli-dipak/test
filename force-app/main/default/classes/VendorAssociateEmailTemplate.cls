public class VendorAssociateEmailTemplate {
    @InvocableMethod(label='create html for tables')
    public static List<Response> sendEmailtoVendor(List<Request> requestData) {
        List<Response> responseList=new List<Response>();        
        Response responseData=new Response();
        responseData.LobTableHtml='';
        responseData.ConTableHtml='';
        
        Map<String,String> LOBNameToAbbreviaion=new Map<String,String>();
        for(Risk_Engineering_related_LOB__mdt md:[select id,Label, LOB_Abbriviation__c from Risk_Engineering_related_LOB__mdt ]){
            LOBNameToAbbreviaion.put(md.Label,md.LOB_Abbriviation__c);
        }
        List<String> LocationList=new List<String>();
        for(Location_And_Line_Of_Business__c llob:[Select id,Location_Name__c from Location_And_Line_Of_Business__c where Case__r.id=:(requestData[0].CaseId)]){
            LocationList.add(llob.Location_Name__c);
        }
        
        String LobAbbreviationName;
        
        LOB_Management__c LobManagementRecord= [select Id,Name,Line_of_Business__c ,Estimated_LOB_Premium__c, LOB_Effective_Date__c from LOB_Management__c where Case__c=: (requestData[0].CaseId) LIMIT 1];
        
        Map<String, Set<String>> LOBToProductNames = new Map<String, Set<String>>();
        for (RiskEngProductMapping__mdt mapping : [SELECT LOB_RecordTypeName__c, ProductName__c FROM RiskEngProductMapping__mdt]) {
            if (!LOBToProductNames.containsKey(mapping.LOB_RecordTypeName__c)) {
                LOBToProductNames.put(mapping.LOB_RecordTypeName__c, new Set<String>());
            }
            LOBToProductNames.get(mapping.LOB_RecordTypeName__c).add(mapping.ProductName__c);
        }
        
        Set<String> productNames = new Set<String>();
        for (String lob : LOBToProductNames.keySet()) {
            if (lob == LobManagementRecord.Line_of_Business__c) {
                productNames.addAll(LOBToProductNames.get(lob));
            }
        }
        //generate LOB table
        if(LobManagementRecord != null){
            LobAbbreviationName=LOBNameToAbbreviaion.get(LobManagementRecord.Line_of_Business__c);
           
            
                
                Integer i=0;
                String policyNumbers='';
                for(InsurancePolicy pl:[Select id,Name, Product_Name__c from InsurancePolicy where Case__c =:(requestData[0].CaseId) and Product_Name__c In : productNames]){
                    if(i==0){
                        policyNumbers+=pl.Name;
                    }else{
                        policyNumbers+='<br/>'+pl.Name;
                    }
                    i++;
                }
                
                String estimatedPremium=null;
                if(String.valueOf(LobManagementRecord.Estimated_LOB_Premium__c)!=null){
                    Decimal premium= LobManagementRecord.Estimated_LOB_Premium__c;
                    estimatedPremium = '$' + premium.format();
                }
                
                responseData.LobTableHtml += '<table border="1">'
                    + '<tr>'
                    + '<th style="font-family: Arial, sans-serif; font-size: 12px;">LOB</th>'
                    + '<th style="font-family: Arial, sans-serif; font-size: 12px;">Policy Number (if bound)</th>'
                    +'<th style="font-family: Arial, sans-serif; font-size: 12px;">Effective Date</th>'
                    + '<th style="font-family: Arial, sans-serif; font-size: 12px;">Estimated or Actual Premium</th>'
                    + '</tr>' 
                    + '<tr>'
                    + '<td style="font-family: Arial, sans-serif; font-size: 12px;">'+LobManagementRecord.Line_of_Business__c+'</td>'
                    +'<td style="text-align:center;font-family: Arial, sans-serif; font-size: 12px;">'+policyNumbers+'</td>'
                    + '<td style="text-align:center;font-family: Arial, sans-serif; font-size: 12px;">'+(String.valueOf(LobManagementRecord.LOB_Effective_Date__c) != null?String.valueOf(LobManagementRecord.LOB_Effective_Date__c):'')+'</td>'
                    + '<td style="text-align:center;font-family: Arial, sans-serif; font-size: 12px;">'+(estimatedPremium != null?estimatedPremium:'')+'</td>'
                    +'</tr>'
                    +'</table>';
                
                system.debug('@@responseData.LobTableHtml::'+responseData.LobTableHtml);
            
        }
        
        //system.debug('@@requestData[0].locationList::'+requestData[0].locationList);
        //generate LOC table
        if(requestData[0].locationList != null){
            if((requestData[0].locationList.size())>0){
                Map<String,String> locationIdWithAddressMap=new Map<String,String>();
                for(CaseAndLocaiton__c ltn:requestData[0].locationList){
                    locationIdWithAddressMap.put(ltn.Location__c,ltn.Location_Adress__c);
                }
                
                system.debug('@@locationIdWithAddressMap::'+locationIdWithAddressMap);
                system.debug('@@contacts::'+[select id,Contact_Name__c, Contact__r.Email, Contact__r.Phone,Location__c from Location_And_Contact__c where Location__c =:(locationIdWithAddressMap.keySet())]);
                
                Map<String,List<Location_And_Contact__c>> LocationIdWithContactsMap=new Map<String,List<Location_And_Contact__c>>();
                for(Location_And_Contact__c lac:[select id,Contact__r.Name, Contact__r.Email, Contact__r.Phone,Location__c,Case__c  from Location_And_Contact__c where Location__c =:(locationIdWithAddressMap.keySet())]){
                    if(!LocationIdWithContactsMap.containsKey(lac.Location__c)){
                        LocationIdWithContactsMap.put(lac.Location__c,new List<Location_And_Contact__c>());
                    }
                    LocationIdWithContactsMap.get(lac.Location__c).add(lac);
                }
                system.debug('@@LocationIdWithContactsMap::'+LocationIdWithContactsMap);
                
                List<String> LocRowList=new List<String>();
                
                if(requestData[0].NoLocationTrue == false){
                    responseData.ConTableHtml += '<table border="1">'
                        + '<tr>'
                        + '<th style="font-family: Arial, sans-serif; font-size: 12px;">Location Address</th>'
                        + '<th style="font-family: Arial, sans-serif; font-size: 12px;">Location Contact Name</th>'
                        +'<th style="font-family: Arial, sans-serif; font-size: 12px;">Location Contact Number</th>'
                        + '<th style="font-family: Arial, sans-serif; font-size: 12px;">Location Contact Email</th>'
                        + '<th style="font-family: Arial, sans-serif; font-size: 12px;">Coverage To Review</th>'
                        + '</tr>';
                }else {
                    responseData.ConTableHtml += '<table border="1">'
                        + '<tr>'
                        + '<th style="font-family: Arial, sans-serif; font-size: 12px;">Contact Name</th>'
                        +'<th style="font-family: Arial, sans-serif; font-size: 12px;">Contact Number</th>'
                        + '<th style="font-family: Arial, sans-serif; font-size: 12px;">Contact Email</th>'
                        + '<th style="font-family: Arial, sans-serif; font-size: 12px;">Coverage To Review</th>'
                        + '</tr>';
                }
                
                for(String loc: locationIdWithAddressMap.keySet()){ 
                    string address=locationIdWithAddressMap.get(loc);
                    string coverage=LobAbbreviationName;
                    
                    if(!LocRowList.contains(loc)){
                        LocRowList.add(loc);
                        
                        
                        if(LocationIdWithContactsMap.containsKey(loc) && LocationIdWithContactsMap.get(loc) != null){
                            responseData.ConTableHtml += '<tr>'
                                +((requestData[0].NoLocationTrue == false) ? '<td style="font-family: Arial, sans-serif; font-size: 12px;" >'+address+'</td>' : '');
                            
                            
                            string cntName='<table>';
                            string cntPhone='<table>';
                            string cntEmail='<table>';
                            for(Integer i=0;i<LocationIdWithContactsMap.get(loc).size();i++){
                                if((LocationIdWithContactsMap.get(loc)[i]).Case__c == (requestData[0].CaseId)){
                                    cntName+='<tr><td style="padding-bottom:0px;padding-top:0px;font-family: Arial, sans-serif; font-size: 12px">'+(LocationIdWithContactsMap.get(loc)[i]).Contact__r.Name+'</td></tr>';
                                    cntPhone+='<tr><td style="padding-bottom:0px;padding-top:0px;font-family: Arial, sans-serif; font-size: 12px">'+((LocationIdWithContactsMap.get(loc)[i]).Contact__r.Phone!=null?(LocationIdWithContactsMap.get(loc)[i]).Contact__r.Phone:'<br/>')+'</td></tr>';
                                    cntEmail+='<tr><td style="padding-bottom:0px;padding-top:0px;font-family: Arial, sans-serif; font-size: 12px">'+((LocationIdWithContactsMap.get(loc)[i]).Contact__r.Email!=null?(LocationIdWithContactsMap.get(loc)[i]).Contact__r.Email:'<br/>')+'</td></tr>';
                                }
                            }
                            cntName+='</table>';
                            cntPhone+='</table>';
                            cntEmail+='</table>';
                            
                            responseData.ConTableHtml +='<td style="font-family: Arial, sans-serif; font-size: 12px;">'+cntName+'</td>'
                                +'<td style="font-family: Arial, sans-serif; font-size: 12px;">'+cntPhone+'</td>'
                                +'<td style="font-family: Arial, sans-serif; font-size: 12px;">'+cntEmail+'</td>'
                                + '<td style="font-family: Arial, sans-serif; font-size: 12px;" >'+coverage+'</td>'
                                +'</tr>';
                        } else {
                            responseData.ConTableHtml += '<tr>'
                                +((requestData[0].NoLocationTrue == false) ? '<td style="font-family: Arial, sans-serif; font-size: 12px;" >'+address+'</td>' : '');
                            
                            responseData.ConTableHtml +='<td style="font-family: Arial, sans-serif; font-size: 12px;"> </td>'
                                +'<td style="font-family: Arial, sans-serif; font-size: 12px;"> </td>'
                                +'<td style="font-family: Arial, sans-serif; font-size: 12px;"> </td>'
                                + '<td style="font-family: Arial, sans-serif; font-size: 12px;" >'+coverage+'</td>'
                                +'</tr>';
                        }
                    }
                }
                responseData.ConTableHtml +='</table>';
                system.debug('@@responseData.ConTableHtml::'+responseData.ConTableHtml);
            }
        }
        
        responseList.add(responseData);
        return responseList;
    }
    
    public class Request{
        
        @InvocableVariable
        public List<CaseAndLocaiton__c> locationList;
        
        @InvocableVariable
        public String CaseId;
        
        @InvocableVariable
        public Boolean NoLocationTrue;
        
    }
    
    public class Response{
        @InvocableVariable
        public String LobTableHtml;
        
        @InvocableVariable
        public String ConTableHtml;
        
    }
    
}