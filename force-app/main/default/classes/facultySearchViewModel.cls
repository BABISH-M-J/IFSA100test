//Project BlackHole
/**
 * Viewmodl for facultySearch Visualforce page. Used with <<facultySearchController>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/4/2021 Brock Barlow
public with sharing class facultySearchViewModel 
{
    /**
     * The cities in IFSA active countries
     */
    public Set<model_city> cities {get;set;}
    /**
     * IFSA active countries
     */
    public Set<model_country> countries {get;set;}
    /**
     * Home Institution contacts
     */
    public List<model_support_personnel> facultyContacts {get;set;}
    /**
     * Home Institutions
     */
    public Set<model_homeInstitution> homeInstitutions {get;set;}
    /**
     * Host Institutions
     */
    public Set<model_hostInstitution> hostInstitutions {get;set;}
    /**
     * Programs
     */
    public Set<model_program> programs {get;set;}
    /**
     * Parent Program Terms
     */
    public Set<model_program_term> parentProgramTerms {get;set;}
    /**
     * Program Terms
     */
    public Set<model_program_term> programTerms {get;set;}
    /**
     * Student Contacts (by application)
     */
    public Set<model_application> studentContacts {get;set;}
    /**
     * Terms
     */
    public Set<model_term> terms {get;set;}
    /**
     * Message
     */
    public String message {get;set;}
    /**
     * The selected faculty as an instance of <<model_support_personnel>>
     */
    public model_support_personnel selectedFaculty {get;set;}
    /**
     * The selected faculty as an instance of <<model_contact>>
     */
    public model_contact selectedFacultyContact {get;set;}


    /**
     * Constructor initializes collections, gets term and country records
     */
    public facultySearchViewModel() 
    {
        this.initializeLists();
        //Get records and load data model apex objects
        for(Term__c t: [SELECT Id, Name, Year__c, Section__c FROM Term__c WHERE Year__c >=: Date.today().year() - 1 AND Year__c <=: Date.today().year() + 1  ORDER BY Start_Date__c])
        {
            this.terms.add(new model_term(t));
        }

        for(Country__c c: [SELECT Id, Name FROM Country__c WHERE Name != 'Undecided' AND Region__r.Name = 'International Support' AND Active__c = TRUE ORDER BY Name])
        {
            this.countries.add(new model_country(c));
        }
    }

    private void initializeLists()
    {
        // Initialize List variables
        this.cities = new Set<model_city>();
        this.countries = new Set<model_country>();
        this.facultyContacts = new List<model_support_personnel>();
        this.homeInstitutions = new Set<model_homeInstitution>();
        this.hostInstitutions = new Set<model_hostInstitution>();
        this.programs = new Set<model_program>();
        this.parentProgramTerms = new Set<model_program_term>();
        this.programTerms = new Set<model_program_term>();
        this.studentContacts = new Set<model_application>();
        this.terms = new Set<model_term>();
    }
    /**
     * JSON serializes this instance
     * @return String
     */
    public String getSerializedViewModel()
    {
        return JSON.serialize(this);
    }

    /**
     * Deserialize JSON string back to an instance of facultySearchViewModel
     * @param jsonData
     * @return <<facultySearchViewModel>>
     */
    public static facultySearchViewModel parseJSONString(String jsonData)
    {
        facultySearchViewModel viewModel = new facultySearchViewModel();
        if(jsonData == null)
        {
          return null;
        }
        try
        {
            //Remove leading and trailing '"' characters            
            jsonData = jsonData.removeStart('"');
            jsonData = jsonData.removeEnd('"');
            system.debug(jsonData);
            viewModel = (facultySearchViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('facultySearchViewModel'));
            return viewModel;
        }
        catch(Exception e)
        {
          System.debug(LoggingLevel.ERROR, e.getMessage());
          return null;
        }
    }

    // Search Methods
    /**
     * Updates available filters
     */
    public void updateFilters()
    {
        system.debug(this.cities.size());
        this.resetFilters(getCountryIds());
        // Get the cities
        this.searchCities(getCountryIds());
        // Get the Host Institutions
        this.searchHostInstitutions(getCountryIds(), getCityIds());
        // Get the programs
        this.searchPrograms(getCountryIds(), getCityIds(), getHostInsitutionIds());
    }

    /**
     * Searches for cities in the specified countries
     */
    private void searchCities(Set<Id> countryIds)
    {
        Set<model_city> newCities = new Set<model_city>();
        // Get the cities
        for(Locality__c l: [SELECT Id, Name, Country__c FROM Locality__c WHERE Country__c IN: countryIds])
        {
            model_city c = new model_city(l);

            System.debug('Does the set of cities contain a model_city like "c"? ' + this.cities.contains(c));
            newCities.add(c);
        }
        List<model_city> citiesToRemove = new List<model_city>();
        for(model_city nc: newCities)
        {
            for(model_city ec: this.cities)
            {
                if(nc.equals(ec)) citiesToRemove.add(nc);
            }
        }
        Set<model_city> citiesToSave = new Set<model_city>();
        this.cities.addAll(newCities);
        // Remove cities if the countrty has been unselected
        for(model_city mc: this.cities)
        {
            for(String cId: countryIds)
            {
                if(mc.countryId == cId)
                {
                    citiesToSave.add(mc);
                    break;
                }
            }
        }
        cities.retainAll(citiesToSave);
        cities.removeAll(citiesToRemove);
    }

    /**
     * Searches for host institutions in the specified countries and cities
     */
    private void searchHostInstitutions(Set<Id> countryIds, Set<Id> cityIds)
    {
        replaceSpecialChars();
        // Get the host institutions by country and if possible use city.
        List<Host_Institution__c> hostInsts;
        if(cityIds.isEmpty())
            hostInsts = [SELECT Id, Name, Country__c, Locality__c FROM Host_Institution__c WHERE Country__c IN: countryIds];
        else
            hostInsts = [SELECT Id, Name, Country__c, Locality__c FROM Host_Institution__c WHERE Locality__c IN: cityIds OR Country__c IN: countryIds];
        
        Set<model_hostInstitution> newHosts = new  Set<model_hostInstitution>();
        for(Host_Institution__c h: hostInsts)
        {
            model_hostInstitution mh = new model_hostInstitution(h);
            System.debug('Does the set of cities contain a model_hostInstitution like "mh"? ' + this.hostInstitutions.contains(mh));
            newHosts.add(mh);
        }
        List<model_hostInstitution> hostsToRemove = new List<model_hostInstitution>();
        for(model_hostInstitution nc: newHosts)
        {
            for(model_hostInstitution ec: this.hostInstitutions)
            {
                if(nc.equals(ec)) hostsToRemove.add(nc);
            }
        }
        Set<model_hostInstitution> hostInstsToSave = new Set<model_hostInstitution>();
        this.hostInstitutions.addAll(newHosts);
        // Remove host insitutiions if country or city has been unselected
        for(model_hostInstitution mh: this.hostInstitutions)
        {
            if(cityIds.isEmpty())
            {
                for(String coId: countryIds)
                {
                    //system.debug(mh);
                    if(mh.countryId == coId)
                    {
                        hostInstsToSave.add(mh);
                        break;
                    }
                }
            }

            for(String ciId: cityIds)
            {
                if(mh.localityId == ciId)
                {
                    hostInstsToSave.add(mh);
                    break;
                }
            }
        }
        hostInstitutions.retainAll(hostInstsToSave);
        hostInstitutions.removeAll(hostsToRemove);
    }

    /**
     * Searches for programs in the specified countries, cities and host institutions
     */ 
    private void searchPrograms(Set<Id> countryIds, Set<Id> cityIds, Set<Id> hostInstitutionIds)
    {
        replaceSpecialChars();
        // Get the programs by country and if possible use city and/or host institution
        List<Program__c> programsList;
        if(cityIds.isEmpty() && hostInstitutionIds.isEmpty())
            programsList = [SELECT Id, Name, Country__c, Country_Name__c, Locality__c, Host_Institution__c FROM Program__c WHERE Country__c IN: countryIds];
        else if(cityIds.isEmpty() && !hostInstitutionIds.isEmpty())
            programsList = [SELECT Id, Name, Country__c, Country_Name__c, Locality__c, Host_Institution__c FROM Program__c WHERE Host_Institution__c IN: hostInstitutionIds OR Country__c IN: countryIds];
        else if(!cityIds.isEmpty() && hostInstitutionIds.isEmpty())
            programsList = [SELECT Id, Name, Country__c, Country_Name__c, Locality__c, Host_Institution__c FROM Program__c WHERE Locality__c IN: cityIds OR Country__c IN: countryIds];
        else
            programsList = [SELECT Id, Name, Country__c, Country_Name__c, Locality__c, Host_Institution__c FROM Program__c WHERE Host_Institution__c IN: hostInstitutionIds OR Locality__c IN: cityIds OR Country__c IN: countryIds];
        Set<model_program> newPrograms = new Set<model_program>();
        for(Program__c p: programsList)
        {
            model_program mp = new model_program(p);
            newPrograms.add(mp);
        }
        List<model_program> programsToRemove = new List<model_program>();
        for(model_program nc: newPrograms)
        {
            for(model_program ec: this.programs)
            {
                if(nc.equals(ec)) programsToRemove.add(nc);
            }
        }
        Set<model_program> programsToSave = new Set<model_program>();
        this.programs.addAll(newPrograms);
        // Remove programs if the country, city or host institution has been unselected
        for(model_program mp: this.programs)
        {
            if(!(cityIds.isEmpty() || hostInstitutionIds.isEmpty()))
            {
                for(String coId: countryIds)
                {
                    if(mp.countryId == coId)
                    {
                        programsToSave.add(mp);
                        break;
                    }
                }
            }
            if(hostInstitutionIds.isEmpty())
            {
                for(String ciId: cityIds)
                {
                    if(mp.localityId == ciId)
                    {
                        programsToSave.add(mp);
                        break;
                    }
                }
            }

            for(String hiId: hostInstitutionIds)
            {
                if(mp.hostInstitutionId == hiId)
                {
                    programsToSave.add(mp);
                    break;
                }
            }
        }
        programs.retainAll(programsToSave);
        programs.removeAll(programsToRemove);
    }

    /**
     * Performs a search query on Home Institution Records. Uses 'LIKE' clause in SOQL statement
     * @param searchString
     */
    public void searchHomeInstitutionByName(String searchString)
    {
        for(Home_Institution__c hi: Database.query('SELECT Id, Name, Country__c, Locality__c FROM Home_Institution__c WHERE name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\' LIMIT 200'))
        {
            this.homeInstitutions.add(new model_homeInstitution(hi));
        }
    }

    /**
     * Searches for students and gets their home institution advisors
     */
    public void search()
    {
        // Clear facultyContacts and studentContacts because the advisors will be changing
        this.selectedFaculty = null;
        this.studentContacts.clear();
        this.facultyContacts.clear();
        // List to hold applications that meet the search criteria
        List<Application__c> searchedApps = getApplications();      

        if(searchedApps.size()==0)
        {
            this.message = 'Search returned 0 results';
            return;
        }
        system.debug(searchedApps.size());
        // Build map of Id, List<Application__c> with the applicant Id as the key to a list of applications belonging to the applicant
        Map<Id, List<Application__c>> applicantIds = new Map<Id, List<Application__c>>();
        for(Application__c app: searchedApps)
        {
            if(!applicantIds.containsKey(app.Applicant__c))
                applicantIds.put(app.Applicant__c, new List<Application__c>());
            applicantIds.get(app.Applicant__c).add(app);
        }
        // Use the set of applicants from the map above to get their home institution contact support personnel
        List<Contact_Support_Personnel__c> csps = [SELECT Id, Support_Personnel__c, Contact__c FROM Contact_Support_Personnel__c WHERE Contact__c IN: applicantIds.keySet() AND Support_Personnel__r.IFSA_Staff__c = NULL];
        system.debug(csps.size());
        // Build a map of Id, List<Contact_Support_Personnel__c> with the support_personnel__c id as the key to the list of csp records
        Map<Id, List<Contact_Support_Personnel__c>> facultyIds = new Map<Id, List<Contact_Support_Personnel__c>>();
        for(Contact_Support_Personnel__c csp: csps)
        {
            if(!facultyIds.containsKey(csp.Support_Personnel__c))
                facultyIds.put(csp.Support_Personnel__c, new List<Contact_Support_Personnel__c>());
            facultyIds.get(csp.Support_Personnel__c).add(csp);
        }
        // Use the set of SP ids to get the Support_Personnel__c Records. Use "apexQueryUtility.selectAllFrom" to get the data for all fields on the records and use the optional parameter to get related fields.
        List<Support_Personnel__c> sps = apexQueryUtility.selectAllFrom('Support_Personnel__c', 'Account__r.Name, RecordType.Name, Non_IFSA_Staff__r.LastName, Non_IFSA_Staff__r.Name', 'Id IN ' + apexQueryUtility.buildInClause(facultyIds.keySet()) + 'ORDER BY Non_IFSA_Staff__r.LastName');
        system.debug(sps.size());
        List<model_support_personnel> facultyMSP = new List<model_support_personnel>();
        // Iterate over the list of Support_Personnel__c and instantiate "model_support_personnel" for each record
        for(Support_Personnel__c sp: sps)
        {
            model_support_personnel mc = new model_support_personnel(sp);
            // If by some reason the related contact has been deleted but an SP record still exists use "CONTACT RECORD HAS BEEN DELETED" in the name field
            if(mc.contactName == null || mc.contactName == '')
            {
                mc.contactName = 'CONTACT RECORD HAS BEEN DELETED';
            }
            // Using the applicant id / list of applications map from above sum the number of students that are on-site, traveling, or program completed
            for(Contact_Support_Personnel__c csp: facultyIds.get(sp.Id))
            {
                for(Application__c app: applicantIds.get(csp.Contact__c))
                {
                    if(app.Status__c.contains('Accepted'))
                        mc.numberOfTraveling = mc.numberOfTraveling + 1;
                    else if(app.Status__c == 'On Site')
                        mc.numberOfOnSite = mc.numberOfOnSite + 1;
                    else if(app.Status__c == 'Program Completed')
                        mc.numberOfProgramCompleted = mc.numberOfProgramCompleted + 1;
                }
            }
            // add the "model_support_personnel" to the list
            facultyMSP.add(mc);
        }
        system.debug(facultyMSP.size());
        // Clear out the list "this.facultyContacts" on the viewModel and addAll items in "facultyMSP" to "this.facultyContacts"
        this.facultyContacts.clear();
        this.facultyContacts.addAll(facultyMSP);
        system.debug(this.facultyContacts.size());
        replaceSpecialChars();
    }

    /**
     * Loads student data
     */
    public void getStudents()
    {
        this.studentContacts.clear();
        List<Application__c> searchedApps = getApplications();

        List<Contact_Support_Personnel__c> csps = [SELECT Id, Support_Personnel__c, Contact__c FROM Contact_Support_Personnel__c WHERE Support_Personnel__c =: this.selectedFaculty.supportPersonnelId];
        system.debug(csps.size());
        Map<Id, List<Contact_Support_Personnel__c>> facultyIds = new Map<Id, List<Contact_Support_Personnel__c>>();
        for(Contact_Support_Personnel__c csp: csps)
        {
            for(Application__c app: searchedApps)
            {
                if(csp.Contact__c == app.Applicant__c)
                {
                    this.studentContacts.add(new model_application(app));
                }
            }
        }
        replaceSpecialChars();
        system.debug(this.studentContacts.size());
    }
    /**
     * Gets the contact info for the selected faculty
     */
    public void getFacultyContact()
    {
        this.selectedFacultyContact = new model_contact((Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + this.selectedFaculty.nonIfsaStaffId + '\'').get(0));
        system.debug(selectedFacultyContact);
    }

    /**
     * Replaces encoded characters
     */
    private void replaceSpecialChars()
    {
        for(model_support_personnel msp: this.facultyContacts)
        {
            if(msp.accountName != null)
            {
                msp.accountName = msp.accountName.replace('&#39;', '\'');
                msp.accountName = msp.accountName.replace('&amp;', '&');
            }
        }
        if(this.selectedFaculty != null && this.selectedFaculty.accountName != null)
        {
            this.selectedFaculty.accountName = this.selectedFaculty.accountName.replace('&#39;', '\'');
            this.selectedFaculty.accountName = this.selectedFaculty.accountName.replace('&amp;', '&');  
        }
        
        for(model_hostInstitution mh: this.hostInstitutions)
        {
            mh.recordName = mh.recordName.replace('&#39;', '\'');
        }
        for(model_program mp: this.programs)
        {
            mp.recordName = mp.recordName.replace('&#39;', '\'');
        }
        for(model_application ma: this.studentContacts)
        {
            ma.programTermName = ma.programTermName.replace('&#39;', '\'');
            ma.programTermName = ma.programTermName.replace('&amp;', '&');
            ma.studentName = ma.studentName.replace('&#39;', '\'');
            if(ma.status == 'Accepted')
            {
                ma.status = 'Travelling';
            }
        }
    }

    /**
     * Gets the applications that match the selected filters
     */
    private List<Application__c> getApplications()
    {
        List<Application__c> results;
        // Sets to hold Ids of search criteria
        Set<Id> countryIds = getCountryIds();
        Set<Id> cityIds = getCityIds();
        Set<Id> termIds = getTermIds();
        Set<Id> hostInstitutionIds = getHostInsitutionIds();
        Set<Id> programIds = getProgramIds();
        system.debug('Looking for applications');
        // Find applications that meet the search criteria
        if(!programIds.isEmpty())
        {
            results = [SELECT Id, Applicant__c, Student_First_Name__C, Student_Last_Name__c, Status__c, Program_Term__r.Name FROM Application__c WHERE (Status__c IN ('On Site', 'Program Completed', 'Withdraw') OR (Status__c LIKE 'Accepted%' AND Applicant__r.Traveling_Status__c = 'Pre-Program')) AND Program_Term__r.Program__c IN: programIds AND Program_Term__r.Term__c IN: termIds];
        }
        else if(!hostInstitutionIds.isEmpty())
        {
            results = [SELECT Id, Applicant__c, Student_First_Name__C, Student_Last_Name__c, Status__c, Program_Term__r.Name FROM Application__c WHERE (Status__c IN ('On Site', 'Program Completed', 'Withdraw') OR (Status__c LIKE 'Accepted%' AND Applicant__r.Traveling_Status__c = 'Pre-Program')) AND Program_Term__r.Program__r.Host_Institution__c IN: hostInstitutionIds AND Program_Term__r.Term__c IN: termIds];
        }
        else if(!cityIds.isEmpty())
        {
            results = [SELECT Id, Applicant__c, Student_First_Name__C, Student_Last_Name__c, Status__c, Program_Term__r.Name FROM Application__c WHERE (Status__c IN ('On Site', 'Program Completed', 'Withdraw') OR (Status__c LIKE 'Accepted%' AND Applicant__r.Traveling_Status__c = 'Pre-Program')) AND Program_Term__r.Program__r.Host_Institution__r.Locality__c IN: cityIds AND Program_Term__r.Term__c IN: termIds];
        }
        else if(!countryIds.isEmpty())
        {
            results = [SELECT Id, Applicant__c, Student_First_Name__C, Student_Last_Name__c, Status__c, Program_Term__r.Name FROM Application__c WHERE (Status__c IN ('On Site', 'Program Completed', 'Withdraw') OR (Status__c LIKE 'Accepted%' AND Applicant__r.Traveling_Status__c = 'Pre-Program')) AND Program_Term__r.Country__c IN: countryIds AND Program_Term__r.Term__c IN: termIds];
        }

        return results;
    }

    // Filter Reset Methods
    /**
     * Resets filters
     */
    public void resetFilters()
    {
        for(model_term mt: this.terms)
        {
            mt.selectedInSearch = false;
        }
        for(model_country mc: this.countries)
        {
            mc.selectedInSearch = false;
        }
        this.facultyContacts = new List<model_support_personnel>();
        this.selectedFaculty = null;
        this.resetFilters(getCountryIds());
    }

    // Parameterized function is called from inside an instance of the class, see function above for example
    /**
     * Resets filters, clears cities, programs and host institutions if the parameter is null
     * @param countryIds
     */
    private void resetFilters(Set<Id> countryIds)
    {
        if(countryIds.isEmpty())
        {
            this.cities.clear();
            this.programs.clear();
            this.hostInstitutions.clear();
        }
    }

    //Get the Id value from the model objects
    /**
     * Gets the Ids for instances in this.cities 
     */
    private Set<Id> getCityIds()
    {
        Set<Id> cityIds = new Set<Id>();
        for(model_city c: this.cities)
        {
            if(c.selectedInSearch)
            {
                cityIds.add(c.localityId);
            }
        }
        return cityIds;
    }
    /**
     * Gets the Ids for instances in this.countries 
     */
    private Set<Id> getCountryIds()
    {
        Set<Id> countryIds = new Set<Id>();
        for(model_country c: this.countries)
        {
            if(c.selectedInSearch)
            {
                countryIds.add(c.countryId);
            }
        }
        return countryIds;
    }
    /**
     * Gets the Ids for instances in this.hostInstitutions 
     */
    private Set<Id> getHostInsitutionIds()
    {
        Set<Id> hostInstitutionIds = new Set<Id>();
        for(model_hostInstitution hi: this.hostInstitutions)
        {
            if(hi.selectedInSearch)
            {
                hostInstitutionIds.add(hi.hostInstitutionId);
            }
        }

        return hostInstitutionIds;  
    }
    /**
     * Gets the Ids for instances in this.programs 
     */
    private Set<Id> getProgramIds()
    {
        Set<Id> programIds = new Set<Id>();
        for(model_program p: this.programs)
        {
            if(p.selectedInSearch)
            {
                programIds.add(p.programId);
            }
        }
        return programIds;  
    }
    /**
     * Gets the Ids for instances in this.terms 
     */
    private Set<Id> getTermIds()
    {
        Set<Id> termIds = new Set<Id>();
        for(model_term t: this.terms)
        {
            if(t.selectedInSearch)
            {
                termIds.add(t.termId);
            }
        }
        return termIds;
    }
}