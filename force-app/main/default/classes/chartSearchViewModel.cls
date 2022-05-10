/**
 * Viewmodel class used with <<chartSearchController>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public without sharing class chartSearchViewModel extends chartBaseViewModel
{
	/**
	 * The list of courses a user can view
	 */
	public List<model_course> courseResults { get; set; }
	/**
	 * The search term used by a user
	 */
	public String searchTerm { get; set; }
	/**
	 * The type of search performed by the user
	 */
	public String searchType { get; set; }
	/**
	 * A list of messages that appear will CHART is loading. (These are not viewed by the user at this time)
	 */
	public List<String> loadingMessages { get; set; }
	/**
	 * A list of the course Ids a student can view
	 */
	public List<Id> courseIds { get; set; }
	/**
	 * The name of the user's user profile. CHART is used by a number of different user types and the experience changes depending on who is viewing the site
	 */
	public String userProfileName { get; set; }
	/**
	 * The names of term sections, used with CI / CE forms
	 */
	public List<String> termNames { get; set; }
	/**
	 * The names of IFSA's program reigions, used with CI / CE forms
	 */
	public List<String> regionNames { get; set; }
	/**
	 * The countries that IFSA has programs in, used with CI / CE forms
	 */
	public List<model_country> countries { get; set; }
	/**
	 * IFSA's programs, used with CI / CE forms
	 */
	public List<model_program> programs { get; set; }
	/**
	 * Upcomming term years, used with CI / CE forms
	 */
	public List<Integer> years { get; set; }
	/**
	 * A list of applications for the current user, if they are a student, used in providing links to the student portal and specifically to the student's Class Interest Form(s)
	 */
	public List<Application__c> applications { get; set; }
	/**
	 * A list of Majors, from the contact object's Major_New__c picklist
	 */
	public List<String> majors { get; set; }
	/**
	 * An Id of a completed class matching project. A link is sent to a user when a CMP has been completed and the link has the Id of the completed CMP record which allows CHART to load directly to the results
	 */
	public String cmpId { get; set; }
	/**
	 * The Id of the user's home institutuion account
	 */
	public String homeInstitutionAccountId { get; set; }
	/**
	 * The name of the user's home institution
	 */
	public String homeInstitutionName { get; set; }
	/**
	 * A list of reasons why a class equivalency might be denied
	 */
	public List<String> ceDeniedReasons { get; set; }
	/**
	 * A list of student user's CIF Application_Item__c 
	 */
	public List<Application_Item__c> cifAppItems { get; set; }
	/**
	 * Constructor, initializes the objects lists, and gets default values, or populates lists that are used inside of CHART
	 */
	public chartSearchViewModel()   
	{
		this.courseIds = new List<Id>();
		this.courseResults = new List<model_course>();
		this.countries = new List<model_country>();
		this.programs = new List<model_program>();
		this.cifAppItems = new List<Application_Item__c>();

		this.loadingMessages = new List<String>
		{
			'Locating the required gigapixels to render...',
			'Spinning up the hamster...',
			'Shoveling coal into the server...',
			'Programming the flux capacitor',
			'Please wait... at least you\'re not on hold'
		};
		this.userProfileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].get(0).Name;
		this.termNames = apexConversionUtility.getPicklistStringValues(CMP__c.Terms_Abroad__c);
		this.regionNames = apexConversionUtility.getPicklistStringValues(CMP__c.Regions__c);
		this.ceDeniedReasons = apexConversionUtility.getPicklistStringValues(Course_Equivalency__c.Denied_Reason__c);
		List<Country__c> countryRecords;
		if(this.userProfileName.contains('Student'))
		{
			for(Country__c country: [SELECT Id, Name, Marketing_Region__c, (SELECT Id, Name, Country_Name__c, Has_Academic_Year_Program_Terms__c, Has_Calendar_Year_Program_Terms__c, Has_Fall_Program_Terms__c, Has_Spring_Program_Terms__c, Has_Summer_Program_Terms__c, Has_Winter_Program_Terms__c FROM Programs__r WHERE Category__c = 'Catalog' AND Active__c = TRUE AND Id IN (SELECT Program__c FROM Program_Authorization__c WHERE Term__c != 'Not Approved' AND Is_Active__c = TRUE AND Account__c =: chartRemoteMethods.getHomeInstitutionAccount())) FROM Country__c WHERE Active__c = TRUE AND Name != 'United States' AND Name != 'Canada'])
			{
				countries.add(new model_country(country));
				for(Program__c program: country.Programs__r)
				{
					programs.add(new model_program(program));
				}
			}
		}
		else
		{
			Map<Country__c, List<Program__c>> countryMaps = new Map<Country__c, List<Program__c>>();
			List<Program__c> progs = [SELECT Id, Name, Country__c, Country_Name__c, Has_Academic_Year_Program_Terms__c, Has_Calendar_Year_Program_Terms__c, Has_Fall_Program_Terms__c, Has_Spring_Program_Terms__c, Has_Summer_Program_Terms__c, Has_Winter_Program_Terms__c,
					(SELECT Id, Name, Account__c, Program__c, Program__r.Name, Program__r.Country__r.Name, Term__c, Do_Not_Allow_Students_To_Apply__c FROM Program_Authorizations__r WHERE Account__c =: chartRemoteMethods.getHomeInstitutionAccount() AND Is_Active__c = TRUE LIMIT 1)
				FROM Program__c
				WHERE Category__c = 'Catalog' AND Active__c = TRUE
			];
			for(Country__c c: [SELECT Id, Name, Marketing_Region__c FROM Country__c WHERE Active__c = TRUE AND Name != 'United States' AND Name != 'Canada'])
			{
				countryMaps.put(c, new List<Program__c>());
				countries.add(new model_country(c));
			}
			for(Program__c p: progs)
			{
				programs.add(new model_program(p));
			}
		}
		this.years = new List<Integer>{Date.today().year(), (Date.today().year() + 1), (Date.today().year() + 2)};
		this.majors = apexConversionUtility.getPicklistStringValues(CMP__c.Major__c);
	}
}