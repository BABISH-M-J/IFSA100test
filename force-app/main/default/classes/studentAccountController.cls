/**
 * <h2>studentAccountController</h2>
 * <h3>Controller for the Student Portal Account Page.</h3>
 * <p>
 * Obtains the list of charges and payements against a student
 * account and displays them, along with the option to pay now.
 * </p>
 * 
 * @author Cameron Ames and FinancialForce
 */
public without sharing class studentAccountController extends studentBaseController
{
  public studentAccountViewModel viewModel {get;set;}
    public Application__c apList  {get;set;}
    public Id conId    {get; set;}
    public set<Id> prgmIdset = new set<Id>();
    public List<Product2> prd{get;set;}

  private List<Application__c> applicationList {get;set;}
    private List<Program_Term__c> programList{get;set;}
    private List<PricebookEntry> pricebookEntries {get; set;}
    private set<Id> applicationIds = new set<Id>();
    public boolean doDML {get;set;}

  public studentAccountController()
  {
    super();
    this.doDML = false;
    this.viewModel = new studentAccountViewModel();
    System.debug(this.studentContact);
    this.viewModel.street = this.studentContact.MailingStreet != null ? EncodingUtil.urlEncode(this.studentContact.MailingStreet, 'UTF-8'): null;
    this.viewModel.city = this.studentContact.MailingCity != null ? EncodingUtil.urlEncode(this.studentContact.MailingCity, 'UTF-8'): null;
    this.viewModel.state = this.studentContact.MailingState != null ? EncodingUtil.urlEncode(this.studentContact.MailingState, 'UTF-8'): null;
    this.viewModel.zipCode = this.studentContact.MailingPostalCode != null ? EncodingUtil.urlEncode(this.studentContact.MailingPostalCode, 'UTF-8'): null;
    this.viewModel.email = this.studentContact.Email != null ? EncodingUtil.urlEncode(this.studentContact.Email, 'UTF-8'): null;

    this.applicationList = [SELECT Id, Name, Application_Balance__c, Program_Term__c, Program_Term__r.Program__c FROM Application__c WHERE Applicant__c =: this.studentContact.Id];

        this.viewModel.cashRecords = [SELECT Id, Name,Total_Amount__c,Applicant__c,Trade_Date__c from Cash_Entry_Staging__c WHERE Applicant__c =: this.studentUser.ContactId ];
        this.viewModel.cashEntries = [SELECT Id, Name, c2g__Date__c, c2g__PaymentMethod__c, c2g__Account__c, c2g__Value__c FROM c2g__codaCashEntry__c WHERE c2g__Account__c =: this.studentAccount.Id];
        this.viewModel.transactions = [SELECT Id, Name, Amount__c, c2g__AccountValue__c, Date__c, Reference__c, Description__c, Application__c, c2g__Transaction__r.c2g__DocumentNumber__c, c2g__Transaction__r.c2g__TransactionType__c FROM c2g__codaTransactionLineItem__c WHERE Application__c IN: this.applicationList AND Responsible_Party__c = 'Student' AND c2g__Account__c =: this.studentAccount.Id];
    
    for(Application__c application : this.applicationList)
    {
      this.applicationIds.add(application.Program_Term__c);
    }

    this.programList = [SELECT Id, Product__c, Program_Due_Date__c FROM Program_Term__c WHERE ID IN: this.applicationIds];
    List<Pricebook2> standardPbs = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
    if(standardPbs.size() > 0)
    {
          Pricebook2 standardPb = standardPbs.get(0); 
          pricebookEntries = [SELECT ID, UnitPrice FROM PricebookEntry WHERE  Pricebook2ID=:standardPb.id];
    }
    
    
    this.populateViewModel();
  }

  public override PageReference validateAccess()
  {
    if(!this.viewModel.isRegistered)
    {
      return new PageReference('/SP_Register');
    }
    /* List<SObject> inserts = new List<SObject>();
    if(this.doDML)
    {
      Approved_Program__c ap = new Approved_Program__c();
      ap.Home_Institution__c = this.studentContact.Home_Institution__c;
      ap.Program_Term__c = this.application.Program_Term__c;
      inserts.add(ap);

      Task t = new Task();
      t.Subject = 'No Approved Program exists for this student\'s Home Institution';
      t.Description = 'This student\'s school has completed and approved the student to study on this program. ';
      t.Description = t.Description + 'An Approved Program record has been created for the Program Term and Home Institution';
      t.WhatId = this.application.Id;
      t.WhoId = this.application.Applicant__c;
      t.OwnerId = [SELECT Id FROM User WHERE Name = 'Amy Bartnick Blume' AND Profile.Name = 'IFSA Academic Advisors'].get(0).Id;
      inserts.add(t);
    }
    database.insert(inserts); */
    return null;
  }

  private void populateViewModel()
  {
    this.viewModel = (studentAccountViewModel) super.populateViewModel(this.viewModel);    
    Decimal balance = 0;
    for(c2g__codaTransactionLineItem__c tl: this.viewModel.transactions)
    {
      balance = balance + tl.Amount__c;
    }
    this.viewModel.accountTotal = balance;
    this.viewModel.applicationList = new List<studentAccountAppViewModel>();
    for(Program_Term__c pt: programList)
    {
      if(this.application.Program_Term__c == pt.Id)
      {
        this.viewModel.dueDate = pt.Program_Due_Date__c;
      }
    }
    /*
    /*
    for(c2g__codaCashEntry__c cashEntry : this.viewModel.cashEntries)
    {
      this.viewModel.accountTotal -= cashEntry.c2g__Value__c;
    }
    
    this.viewModel.applicationLineItems = [SELECT Id, Name, Charge__c, Type__c, CreatedDate, Product__r.Name FROM Application_Line_Item__c WHERE Application__c IN: this.applicationList AND Bill_Institution__c = false];
    system.debug('Home Institution: ' + this.application.Home_Institution__c);
    system.debug('Program Term: ' + this.application.Program_Term__c);        
    */
    try
    {
      Boolean paysDeposit = [SELECT Pays_Deposit__c FROM Billing_Arrangement__c WHERE Account__c =: this.application.Home_Institution_Account__c AND Program__c =: this.application.Program_Term__r.Program__c].get(0).Pays_Deposit__c;
      if(this.viewModel.cashEntries.isEmpty() && paysDeposit == false)
      {
        this.viewModel.showDepositMessage = true;
      }
      
    }
    catch (Exception ex)
    {
      Application_Item__c progApproval = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Application__c = \'' + this.application.Id + '\' AND RecordType.DeveloperName = \'Program_Approval\'').get(0);
      if(progApproval.Approval_to_Study__c != 'No')
      {
        //Once the VF page loads this flag will allow it to create the program approval and create a task for
        //Amy Bartnick Blume if the student has been approved.        
        //this.doDML = true;
      }
      if(this.viewModel.cashEntries.isEmpty())
      {
        this.viewModel.showDepositMessage = true;        
      }
    }
    IFSA_Payment_Setting__mdt ps = [SELECT Processor_Name__c FROM IFSA_Payment_Setting__mdt WHERE Label = 'Current Processor'].get(0);
        this.viewModel.paymentProcessor = ps.Processor_Name__c;
  }
  
  public pageReference payNow()
  {
        try
        {
          PageReference pg;
          IFSA_Payment_Setting__mdt ps = [SELECT Processor_Name__c, URL__c FROM IFSA_Payment_Setting__mdt WHERE Label = 'Current Processor'].get(0);
          Decimal x = Decimal.valueOf(viewModel.paymentAmount);
          if(ps.Processor_Name__c == 'CashNET')
          {
            pg = new PageReference('https://commerce.cashnet.com/cloudaccountingcheckout'); 
            pg.getParameters().put('name_g',this.studentContact.name);
            pg.getParameters().put('SNAME',this.studentContact.name);
            pg.getParameters().put('addr_g',this.studentContact.MailingStreet);
            pg.getParameters().put('city_g',this.studentContact.MailingCity);
            pg.getParameters().put('desc1','Salesforce to CashNet');
            pg.getParameters().put('state_g',this.studentContact.MailingState);
            pg.getParameters().put('zip_g',this.studentContact.MailingPostalCode);
            pg.getParameters().put('user_email_g',this.studentContact.Email);
            pg.getParameters().put('itemcode1','CA');
            pg.getParameters().put('amount1',this.viewModel.paymentAmount);
            pg.getParameters().put('PARENT RECORD ID',this.studentContact.Id);
            pg.setRedirect(true);
            return pg;
          }
          else
          {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We are sorry but we are unable to process your payment at this time, please try again later.'));
              return null;
          }
        }
        catch(Exception e)
        {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Payment amount should only include numbers and a decimal point.  Please do not enter a comma.'));
            return null;
        }
    }
}