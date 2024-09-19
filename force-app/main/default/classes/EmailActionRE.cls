public class EmailActionRE {
    @InvocableMethod(label='Email Action RE')
    public static void sendEmail(List<Request> requestData) {
        
        System.Debug('----->'+requestData);
        System.Debug('----->'+requestData[0].fileData);
        //	List<Object> get = (List<object>) JSON.deserializeUntyped(requestData[0].fileData);
        //	
        
        // Create a new SingleEmailMessage object
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        // Create a list to hold multiple recipients' email addresses
        List<String> recipients = new List<String>();
        
        for (Request request : requestData) {
            if (!String.isBlank(request.matchedEmailAddress)) {
                // Add email addresses from matchedEmailAddress
                recipients.addAll(getValidEmailAddresses(request.matchedEmailAddress));
            }
            if (!String.isBlank(request.unmatchedEmailAddress)) {
                // Add email addresses from unmatchedEmailAddress
                recipients.addAll(getValidEmailAddresses(request.unmatchedEmailAddress));
            }
        }
        
        // Remove duplicates if needed
        recipients = new List<String>(new Set<String>(recipients));
        
        // Set the target recipient email addresses
        email.setToAddresses(recipients);
        
        // Set the target recipient email address
        //   email.setToAddresses(new String[]{'dipak.koli@psadvisory.com'});
        
        // Set the email subject
        email.setSubject(requestData[requestData.size()-1].EmailSubject);
        
        // Set the email body (HTML content)
        // if(requestData.size()-1)
        email.setHtmlBody(requestData[requestData.size()-1].EmailBody);
        // Fetch the RiskEngineeringEmailAddress from the custom label
        String riskEngineeringEmailAddress = System.Label.RiskEngineeringEmailAddress;
        
        // Query for OrgWideEmailAddress matching the RiskEngineeringEmailAddress
        List<OrgWideEmailAddress> oweaList = [
            SELECT Id, Address, DisplayName 
            FROM OrgWideEmailAddress 
            WHERE Address = :riskEngineeringEmailAddress
        ];
        
        // Check if OrgWideEmailAddress is found and set the OrgWideEmailAddressId if available
        if (!oweaList.isEmpty()) {
            OrgWideEmailAddress orgWideEmail = oweaList[0]; // Get the first matching OrgWideEmailAddress
            email.setOrgWideEmailAddressId(orgWideEmail.Id);
        }
        
        
        //  if(requestData[requestData.size()-1].contentversionlist!=null)
        if (!String.isBlank(requestData[0].fileData)) 
        {
            // Create a list to hold multiple attachments
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            
            List<FileData> fileDataList = (List<FileData>)JSON.deserialize(requestData[0].fileData, List<FileData>.class);
            //  System.Debug('---->Get Data'+get);
            List<String> filedataversionIds = new  List<String>();
            for(FileData file: fileDataList)
            {
                System.debug('---Contentversion'+file.versionId);
                filedataversionIds.add(file.versionId);
            }
            // Query Content Version records and add attachments to the list
            //  List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData, FileExtension FROM ContentVersion WHERE Id = :requestData[requestData.size()-1].contentversionlist];
            List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData, FileExtension FROM ContentVersion WHERE Id = :filedataversionIds];
            
            for (ContentVersion cv : contentVersions) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                // Extract the file extension from the Title or FileExtension field
                String fileExtension = cv.FileExtension != null ? cv.FileExtension : cv.Title.substringAfterLast('.');
                // Set the file name with the proper extension
                attachment.setFileName(cv.Title + '.' + fileExtension);
                attachment.setBody(cv.VersionData);
                attachments.add(attachment);
            }
            
            // Add the list of attachments to the email
            email.setFileAttachments(attachments);}
        email.setWhatId(requestData[requestData.size()-1].CaseId); 
        email.setSaveAsActivity(true); 
        
        // Send the email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        
        // Check for errors
        if (results[0].isSuccess()) {
            System.debug('Email sent successfully');
            
        } else {
            System.debug('Email could not be sent. Error: ' + results[0].getErrors()[0].getMessage());
        }
        return;
    }
    // Helper method to get valid email addresses from a comma-separated string
    private static List<String> getValidEmailAddresses(String addresses) {
        List<String> validAddresses = new List<String>();
        for (String address : addresses.split(',')) {
            address = address.trim();
            if (address != 'null' && !String.isBlank(address)) {
                validAddresses.add(address);
            }
        }
        return validAddresses;
    }
    public class Request{
        
        @InvocableVariable
        public List<ContentVersion> contentversionlist;
        
        @InvocableVariable
        public String matchedEmailAddress;
        
        @InvocableVariable
        public String unmatchedEmailAddress;
        
        @InvocableVariable
        public String EmailSubject;
        
        @InvocableVariable
        public String CaseId;
        
        @InvocableVariable
        public String EmailBody;
        
        @InvocableVariable
        public String fileData;
        
    }
    public class FileData {
        public String filename { get; set; }
        public String versionId { get; set; }
    }
    
    
    
    
}