public without sharing class model_billingArrangement extends model_base
{
    public String billingAuthorizationId {get; set;}
    public String accountId {get; set;}
    public String programId {get; set;}
    public String programName {get; set;}
    public List<String> terms {get; set;}
    public List<String> availableTerms {get; set;}
    public String selectedTerms {get; set;}
    public Boolean directBill {get; set;}
    public Decimal discountAmount {get; set;}
    public String discountRecipient {get; set;}
    public Boolean paysAccomodation {get; set;}
    public Boolean paysDeposit {get; set;}
    public Boolean paysLateWithdrawFee {get; set;}
    public Boolean paysSupAccomFee {get; set;}
    public Boolean paysSupTutFee {get; set;}
    public Boolean paysTuition {get; set;}
    public Boolean springTerm {get; set;}
    public Boolean summerTerm {get; set;}
    public Boolean fallTerm {get; set;}
    public Boolean notApproved {get; set;}
    public Boolean academicYear {get; set;}
    public Boolean calendarYear {get; set;}
    public Boolean selectAllAvalibleTerms {get; set;}
    public Boolean showSpringTerm {get; set;}
    public Boolean showSummerTerm {get; set;}
    public Boolean showFallTerm {get; set;}
    public Boolean showAcademicYear {get; set;}
    public Boolean showCalendarYear {get; set;}
    public Boolean showNotApproved {get; set;}

    public model_billingArrangement() 
    {
        this.availableTerms = new List<String>();
    }

    public model_billingArrangement(Billing_Arrangement__c bArrangement)
    {
        this();
        this.billingAuthorizationId = bArrangement.Id;
        this.recordName = bArrangement.Name;
        this.accountId = bArrangement.Account__c;
        this.programId = bArrangement.Program__c;
        this.programName = bArrangement.Program__r.Name != null ? bArrangement.Program__r.Name : null;
        this.terms = apexConversionUtility.getPicklistStringValues(Billing_Arrangement__c.Term__c);
        this.selectedTerms = bArrangement.Term__c != null ? bArrangement.Term__c : '';
        this.discountAmount = bArrangement.Discount_Amount__c;
        this.discountRecipient = bArrangement.Discount_Recipient__c;
        this.directBill = bArrangement.Direct_Bill__c == true ? true : false;
        this.paysAccomodation = bArrangement.Pays_Accomodation__c == true ? true : false;
        this.paysDeposit = bArrangement.Pays_Deposit__c == true ? true : false;
        this.paysLateWithdrawFee = bArrangement.Pays_Late_Withdraw_Fees__c == true ? true : false;
        this.paysSupAccomFee = bArrangement.Pays_Supplemental_Accommodation_Fees__c == true ? true : false;
        this.paysSupTutFee = bArrangement.Pays_Supplemental_Tuition_Fees__c == true ? true : false;
        this.paysTuition = bArrangement.Pays_Tuition__c == true ? true : false;
    }
    
    public model_billingArrangement(String bArrangementId) 
    {
        this([SELECT Id, Name, Account__c, Direct_Bill__c, Program__r.Name,Discount_Amount__c, Discount_Recipient__c, Pays_Accomodation__c, Pays_Deposit__c, Pays_Late_Withdraw_Fees__c, Pays_Supplemental_Accommodation_Fees__c, Pays_Supplemental_Tuition_Fees__c, Pays_Tuition__c, Program__c, Term__c FROM Billing_Arrangement__c WHERE Id =: bArrangementId]);
    }

    public static model_billingArrangement convertFromJson(String jsonData)
    {
        //Unescape the json string
        jsonData = jsonData.unescapeEcmaScript();
        //Remove leading and trailing '"' characters            
        jsonData = jsonData.removeStart('"');
        jsonData = jsonData.removeEnd('"');
        jsonData = jsonData.replace('\n', '\\n');
        //jsonData = jsonData.replaceAll('T04:00:00.000Z', '');
        system.debug(jsonData);         
        return (model_billingArrangement) JSON.createParser(jsonData).readValueAs(Type.forName('model_billingArrangement'));
    }
    public static List<model_billingArrangement> convertFromJsonToList(String jsonData)
    {
        //Unescape the json string
        jsonData = jsonData.unescapeEcmaScript();
        //Remove leading and trailing '"' characters            
        jsonData = jsonData.removeStart('"');
        jsonData = jsonData.removeEnd('"');
        jsonData = jsonData.replace('\n', '\\n');
        //jsonData = jsonData.replaceAll('T04:00:00.000Z', '');
        system.debug(jsonData);
        return (List<model_billingArrangement>) JSON.deserialize(jsonData, List<model_billingArrangement>.class);
    }

    public String save()
    {
        Billing_Arrangement__c bArrangement = new Billing_Arrangement__c();
        bArrangement.Id = this.billingAuthorizationId != '' ? this.billingAuthorizationId : null;
        if(bArrangement.Id == null)
        {
            bArrangement.Account__c = this.accountId;
        }       
        bArrangement.Program__c = this.programId;
        bArrangement.Term__c = this.selectedTerms;
        bArrangement.Discount_Amount__c = this.discountAmount;
        bArrangement.Discount_Recipient__c = this.discountRecipient;
        bArrangement.Direct_Bill__c = this.directBill == true ? true : false;
        bArrangement.Pays_Accomodation__c = this.paysAccomodation == true ? true : false;
        bArrangement.Pays_Deposit__c = this.paysDeposit == true ? true : false;
        bArrangement.Pays_Tuition__c = this.paysTuition == true ? true : false;

        try 
        {
            Database.upsert(bArrangement);
            this.billingAuthorizationId = bArrangement.Id;
            return bArrangement.Id;
        }
        catch(Exception e)
        {
            throw e;
        }
    }

    private void setBaseValues()
    {
        this.recordId = this.billingAuthorizationId;
        //this.recordName = this.name
        this.sObjectName = 'Billing_Arrangement__c';
    }
    
    public override Boolean equals(Object o)
    {
        if(o instanceof model_billingArrangement)
        {
            model_billingArrangement obj = (model_billingArrangement)o;
            return (this.recordId == obj.recordId && this.recordName == obj.recordName);
        }
        return false;
    }
}