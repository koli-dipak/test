public class DAL_EmailTemplate {
    
    public static EmailTemplate getTaskEmailTemplate(String templateDeveloperName) {
        try {
            return [SELECT Id, Subject, HtmlValue, Body
                    FROM EmailTemplate
                    WHERE DeveloperName = :templateDeveloperName
                    LIMIT 1];
        } catch (QueryException e) {
            // Handle the exception as needed
            return null;
        }
    }
    
    Static public EmailTemplate getEmailTemplateByName(String EmailName){
        return [SELECT Id, HtmlValue, Subject, Name FROM EmailTemplate WHERE Name =: EmailName];
    }

}