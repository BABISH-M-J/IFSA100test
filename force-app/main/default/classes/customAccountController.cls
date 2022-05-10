/**
 * Custom portal account visualforce page controller.
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020.
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class customAccountController extends customBaseController
{	
	public customAccountViewModel viewModel {get;set;}
    public Application__c apList  {get;set;}
    public Id conId    {get; set;}
    public set<Id> prgmIdset = new set<Id>();
    public List<Product2> prd{get; set;}
	public Application__c application {get; set;}
	public User studentUser {get; set;}
	public Contact studentContact {get; set;}
	public Account studentAccount {get; set;}

  	private List<Application__c> applicationList {get; set;}
    private List<Program_Term__c> programList{get; set;}
    private List<PricebookEntry> pricebookEntries {get; set;}
    private set<Id> applicationIds = new set<Id>();
    

	public customAccountController() 
	{
		super();
		
		this.viewModel = new customAccountViewModel();
		
		this.studentUser = (User) apexQueryUtility.selectAllFrom('User', 'Id = \'' + this.userId + '\'').get(0);
		this.studentContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Active_Application__r.Name', 'Id = \'' + this.studentUser.ContactId + '\'').get(0);
		this.studentAccount = (Account) apexQueryUtility.selectAllFrom('Account', 'Id = \'' + this.studentContact.AccountId + '\'').get(0);
		this.application = studentBaseController.getActiveApplication(studentContact);
		this.applicationList = [SELECT Id, Name, Application_Balance__c, Program_Term__c, Program_Term__r.Program__c FROM Application__c WHERE Applicant__c =: this.studentContact.Id];

			this.viewModel.cashRecords = [SELECT Id, Name,Total_Amount__c,Applicant__c,Trade_Date__c from Cash_Entry_Staging__c WHERE Applicant__c =: this.studentUser.ContactId ];
			this.viewModel.cashEntries = [SELECT Id, Name, c2g__Date__c, c2g__PaymentMethod__c, c2g__Account__c, c2g__Value__c FROM c2g__codaCashEntry__c WHERE c2g__Account__c =: this.studentAccount.Id];
			this.viewModel.transactions = [SELECT Id, Name, Amount__c, c2g__AccountValue__c, Date__c, Reference__c, Description__c, Application__c, c2g__Transaction__r.c2g__DocumentNumber__c, c2g__Transaction__r.c2g__TransactionType__c FROM c2g__codaTransactionLineItem__c WHERE Application__c IN: this.applicationList AND Responsible_Party__c = 'Student' AND c2g__Account__c =: this.studentAccount.Id];
		
		for(Application__c application : this.applicationList)
		{
		this.applicationIds.add(application.Program_Term__c);
		}

		this.programList = [SELECT Id, Product__c, Program_Due_Date__c, Program__r.Display_Account_Tab__c FROM Program_Term__c WHERE ID IN: this.applicationIds];
		if(!this.programList.isEmpty())
		{
			this.viewModel.displayAccountTab = this.programList[0].Program__r.Display_Account_Tab__c == 'Yes';
		}
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
		if(this.viewModel.isLockDownActive)
		{
			return new PageReference('/advisorportal/CP_PortalMessage');
		}
   		else if(this.application != null)
		{
			apexErrorUtility.debug(LoggingLevel.INFO, this.application + ' ' + this.viewModel.getSerializedViewModel());
			return null;
		}
		return new PageReference('CP_NoApp');
	}

	private void populateViewModel()
	{
		this.viewModel = (customAccountViewModel) super.populateCustomBaseViewModel(this.viewModel);    
		Decimal balance = 0;
		for(c2g__codaTransactionLineItem__c tl: this.viewModel.transactions)
		{
			balance = balance + tl.Amount__c;
		}
		this.viewModel.accountTotal = balance;
		this.viewModel.applicationList = new List<studentAccountAppViewModel>();
		IFSA_Payment_Setting__mdt ps = [SELECT Processor_Name__c FROM IFSA_Payment_Setting__mdt WHERE Label = 'Current Processor'].get(0);
		this.viewModel.paymentProcessor = ps.Processor_Name__c;
		for(Program_Term__c pt: programList)
		{
			if(this.application.Program_Term__c == pt.Id)
			{
				this.viewModel.dueDate = pt.Program_Due_Date__c;
			}
		}
		
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
			if(this.viewModel.cashEntries.isEmpty())
			{
				this.viewModel.showDepositMessage = true;        
			}
		}
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