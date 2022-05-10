/**************************************************************************************
 * Connect to Cash Entry from Salesforce with student data and seleted product.
 * @author Astrea
 **************************************************************************************/
// ApexDoc updated 1/28/2021 Brock Barlow
public class ConnectToCashEntry{
    public contact con {get; set;}
    public Id conId    {get; set;}
    public set<Id> appIdset = new set<Id>();
    public set<Id> prgmIdset = new set<Id>();
    public List<Application__c> appList {get;set;}
    public List<Program_Offered__c> prgmList{get;set;}
    public List<Product2> prd{get;set;}
    public List<PricebookEntry> pbe1 {get; set;}
    //constructor...
    public ConnectToCashEntry(){
        conId = ApexPages.currentPage().getParameters().get('id');
        prgmList = new List<Program_Offered__c>();
        appList = new List<Application__c>();
        prd = new List<Product2>();
        
        User u = [SELECT Id, ContactId FROM User WHERE id=:userInfo.getUserId() limit 1];
        
        con = [SELECT Id, Name, FirstName , LastName, Phone, Email, MailingCity, MailingCountry, MailingStreet, MailingState
              ,MailingPostalCode from Contact WHERE Id =: u.contactId];   //'003L000000YsNBy'
              
        appList = [SELECT Id, Name, Personal_Interests__c, Program_Offered__c FROM Application__c WHERE Applicant__c =:conId ]; 
        
        if(appList.size() > 0){
            for(Application__c  ap : appList ){
                appIdset.add(ap.id);
            }
        }
        if(appIdset.size() > 0)
            prgmList = [SELECT Id, Product__c FROM Program_Offered__c WHERE ID =:appList[0].Program_Offered__c];
            
        If(prgmList.size() > 0 ){
            for(Program_Offered__c pg : prgmList){
                prgmIdset.add(pg.Product__c);
            }
        }
        if(prgmIdset.size() > 0){
            prd = [SELECT Id FROM Product2 WHERE ID in: prgmIdset];
        }
        set<Id> prdIdset = new set<Id>();
        if(prd.size() > 0){
            for(Product2 prd :prd ){
                prdIdset.add(prd.id);
            }
        }
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        pbe1 = new List<PricebookEntry>();
        pbe1 = [SELECT ID, UnitPrice FROM PricebookEntry WHERE  Pricebook2ID=:standardPb.id];
    }
    //redirection from Salesforce to CashNet...
    public PageReference redirectmethod(){
        PageReference pg = new PageReference('https://commerce.cashnet.com/cloudaccountingcheckouttest');
        pg.getParameters().put('name_g',con.name);
        pg.getParameters().put('addr_g',con.MailingStreet);
        pg.getParameters().put('city_g',con.MailingCity);
        pg.getParameters().put('desc1','Salesforce to CashNet');
        pg.getParameters().put('state_g',con.MailingState);
        pg.getParameters().put('zip_g',con.MailingPostalCode);
        pg.getParameters().put('user_email_g',con.Email);
        pg.getParameters().put('SESSIONID','1233456');
        pg.getParameters().put('itemcode1','CA');
        pg.getParameters().put('amount1',string.valueOf(pbe1[0].UnitPrice));
        pg.getParameters().put('itemcode2','ASTREA');
        pg.getParameters().put('amount2','5');
        pg.getParameters().put('PARENT RECORD ID',con.Id);
        pg.setRedirect(true);
        return pg;
    }
}