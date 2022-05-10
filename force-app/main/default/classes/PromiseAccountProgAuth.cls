public without sharing class PromiseAccountProgAuth {
    public static final String APPROVES_SUMMER = 'Approves_All_Summer_Programs__c';
    public static final String APPROVES_SEMESTER = 'Approves_All_Calendar_Programs__c';
    public static final String APPROVES_WINTER = 'Approves_All_Winter_Programs__c';
    public static final Map<Id, Program__c> activePrograms = new Map<Id, Program__c>([SELECT Id, Name, Has_Academic_Year_Program_Terms__c, Has_Calendar_Year_Program_Terms__c, Has_Fall_Program_Terms__c,Has_Spring_Program_Terms__c, Has_Summer_Program_Terms__c,  Available_Sections__c,Has_Winter_Program_Terms__c FROM Program__c WHERE Active__c = TRUE AND Category__c = 'Catalog' AND Name != 'Undecided' ]);
   
    public PromiseAccountProgAuth(List<Account> accounts) 
    {
        
        System.debug(LoggingLevel.INFO, 'Creating new PromiseAccountProgAuthTest object');
        if(!Test.isRunningTest())
        {
            new Promise(new ProcessSemseterCalendar())
                .then(new ProcessSummer())
                .then(new ProcessWinter())
                .error(new AccountProgAuthPromiseError())
                .done(new AccountProgAuthPromiseDone())
                .execute(accounts);
        }
        else
        {
            new Promise(new ProcessTest())
                .error(new AccountProgAuthPromiseError())
                .done(new AccountProgAuthPromiseDone())
                .execute(accounts);
        }
    }    

    public virtual class AccountProgAuthBase
    {
        @TestVisible
        private List<Account> accounts;

        public virtual void checkInput(Object incomingObject)
        {
            system.debug(incomingObject);
            // Ensure incoming object is not null
            if(incomingObject == null)
            {
                throw new NullPointerException();
            }
            if(incomingObject instanceOf List<Account>)
            {
                accounts = (List<Account>) incomingObject;
            }
            else if(incomingObject instanceOf Exception)
            {
                throw (Exception) incomingObject;
            }
            else 
            {
                System.debug('A different object was supplied and cannot be cast to Account or AsyncException');
                throw new IllegalArgumentException('A different object was supplied and cannot be cast to Account or AsyncException');
            }
        }

        /**
         * Gets the program authorizations for the requested accounts
         * @param   Set<Id> Ids of accounts to get active program authorizations for
         * @return  Map<Id, List<Program_Authorization>> Map of account Ids and related active Program Auth records
         */
        public Map<Id, List<Program_Authorization__c>> getProgramAuthsForAccounts(Set<Id> accountIds)
        {
            Map<Id, List<Program_Authorization__c>> result = new Map<Id, List<Program_Authorization__c>>();
            //PowerFluence by Vinod add By Order By CreatedDate DESC Limit 1 start
            for(Program_Authorization__c pa: [SELECT Id, Account__c, Program__c, Term__c, Next__c, Previous__c FROM Program_Authorization__c WHERE Account__c IN: accountIds AND Is_Active__c = TRUE AND Program__r.Active__c = TRUE Order By CreatedDate DESC Limit 1 ])
            {
                 //PowerFluence by Vinod add By Order By CreatedDate DESC Limit 1 Ended
                system.debug('pa' + pa);
            

                if(!result.containsKey(pa.Account__c))
                {
                    result.put(pa.Account__c, new List<Program_Authorization__c>());
                }
                result.get(pa.Account__c).add(pa);
            }
            return result;
        }

        /**
         * Gets only the account Ids where the specified field is checked
         * @param   List<Account> The accounts to check
         * @param   String The field to check
         * @return  Set<Id> The accounts that have the checkbox checked
         */
        public Set<Id> getAccountThatApproveAll_Programs(String fieldName)
        {
            Set<Id> result = new Set<Id>();
            for(Account a: accounts)
            {
                Boolean approves = (Boolean) a.get(fieldName);
                if(approves)
                {
                    result.add(a.Id);
                }
            }
            return result;
        }

        public String addSectionToApprovedTerms(String current, String sectionName)
        {
            if(current != null && current != '' && !current.contains(sectionName))
            {
                current = current + ';' + sectionName;
            }
            else if(current == null || current == '')
            {
                current = sectionName;    
            }
            return current;
        }

        public Database.UpsertResult[] approvePrograms(String sectionName, Map<String, String> fieldValueMap)
        {
            Set<Id> accountIds = getAccountThatApproveAll_Programs(sectionName);
            Map<Id, List<Program_Authorization__c>> accountProgAuthMap = getProgramAuthsForAccounts(accountIds)
                ;
            Map<Id, Program_Authorization__c> updatedProgAuthsMap = new Map<Id, Program_Authorization__c>();
            List<Program_Authorization__c> updatedProgAuthsList = new List<Program_Authorization__c>();
            for(Id accountId: accountIds)
            {
                Set<Id> programIds = new Set<Id>();
                // Ensure existing program authorization records have every Semester/Year option
                if(accountProgAuthMap.containsKey(accountId))
                {
                     
                    for(Program_Authorization__c pa: accountProgAuthMap.get(accountId))
                    {
                        system.debug('pa' + pa);
                        //system.debug('pa' + pa.size());
                        programIds.add(pa.Program__c);
                        system.debug('programIds' + programIds);
                       Program__c p = activePrograms.get(pa.Program__c);
                        for(String key: fieldValueMap.keySet())
                        {
                            
                           system.debug('key' +  key);
                        
                           // system.debug('fieldValueMap' + fieldValueMap.get(key));
                            if( ((Boolean) p.get(key)) && (pa.Term__c == null || !pa.Term__c.contains(fieldValueMap.get(key))))
                            {
                              
                                system.debug('getdata one three eight '+ p.get(key));
                                system.debug('p one three nine' + p);
                                system.debug('pa one four zero' + pa);
                                
                                pa.Term__c = addSectionToApprovedTerms(pa.Term__c, fieldValueMap.get(key));
                               // system.debug('pa' + pa.Term__c);
                                 //powerfluence start req.no.10-b 001
 //                               if (pa.Term__c.replace('Not Approved', '').replace(' ','').replace(';','').length() > 0) {
   //                                 pa.Term__c = pa.Term__c.replace('Not Approved', '');
     //                              pa.Term__c = pa.Term__c.replace('; ;', ';');
       //                        }
                                // powerfluence end req.no.10-b 001
                                updatedProgAuthsMap.put(pa.Id, pa);
                                system.debug('updatedProgAuthsMap' + updatedProgAuthsMap);
                            }
          
                        }
                    }
                }
                // Ensure programs without program authorizations for the account get created
                for(Id programId: activePrograms.keySet())
                {
                    system.debug('programId' + programId );
                    if(!programIds.contains(programId))
                    {
                        Program__c p = activePrograms.get(programId);
                        system.debug('one six six'  + p);
                        Program_Authorization__c pa = new Program_Authorization__c(Program__c = programId, Account__c = accountId, Term__c = '');
                        for(String key: fieldValueMap.keySet())
                        {
                            system.debug('key' + key);
                            if((Boolean) p.get(key) && (pa.Term__c == null || !pa.Term__c.contains(fieldValueMap.get(key))))
                            {
                                pa.Term__c = addSectionToApprovedTerms(pa.Term__c, fieldValueMap.get(key));
                                // powerfluence start req.no.10-b 002
//                                if (pa.Term__c.replace('Not Approved', '').replace(' ','').replace(';','').length() > 0) {
//                                    pa.Term__c = pa.Term__c.replace('Not Approved', '');
//                                    pa.Term__c = pa.Term__c.replace('; ;', ';');
//                                }
                                // powerfluence end req.no.10-b 002
                            }
                        }
                        // Only insert the record if term__c has a value
                        if(pa.Term__c != null && pa.Term__c != '')
                        {
                            updatedProgAuthsList.add(pa);
                            system.debug('updatedProgAuthsList' + updatedProgAuthsList);
                        }
                    }
                }
            }
            System.debug('New record count: ' + updatedProgAuthsList);
            updatedProgAuthsList.addAll(updatedProgAuthsMap.values());
            for(Program_Authorization__c pa: updatedProgAuthsList)
            {
                System.debug('palineone eight seven' + pa);
            }
            system.debug('updatedProgAuthsList' +  updatedProgAuthsList);
            system.debug('updatedProgAuthsList' +  updatedProgAuthsList.size());
            return Database.upsert(updatedProgAuthsList);
        }
    }

    public class ProcessSemseterCalendar extends AccountProgAuthBase implements Promise.Deferred
    {
        private final Map<String, String> fieldValueMap = new Map<String, String>{
            'Has_Academic_Year_Program_Terms__c' => 'Academic Year',
            'Has_Calendar_Year_Program_Terms__c' => 'Calendar Year',
            'Has_Fall_Program_Terms__c' => 'Fall',
            'Has_Spring_Program_Terms__c' => 'Spring'            
        };
        public object resolve(Object incomingObject)
        {
            system.debug('incomingObject' + incomingObject);
            super.checkInput(incomingObject);
            system.debug('incomingObject' + incomingObject);
            Database.UpsertResult[] results = approvePrograms(APPROVES_SEMESTER, fieldValueMap);
            return accounts;
        }
    }

    public class ProcessSummer extends AccountProgAuthBase implements Promise.Deferred
    {
        private final Map<String, String> fieldValueMap = new Map<String, String>{
            'Has_Summer_Program_Terms__c' => 'Summer'            
        };
        public object resolve(Object incomingObject)
        {
            super.checkInput(incomingObject);
            
            Database.UpsertResult[] results = approvePrograms(APPROVES_SUMMER, fieldValueMap);
            return accounts;
        }
    }

    public class ProcessWinter extends AccountProgAuthBase implements Promise.Deferred
    {
        private final Map<String, String> fieldValueMap = new Map<String, String>{
            'Has_Winter_Program_Terms__c' => 'Winter'            
        };
        public object resolve(Object incomingObject)
        {
            super.checkInput(incomingObject);

            Database.UpsertResult[] results = approvePrograms(APPROVES_WINTER, fieldValueMap);
            return accounts;
        }
    }

    public class ProcessTest extends AccountProgAuthBase implements Promise.Deferred
    {
        public object resolve(Object incomingObject)
        {
            super.checkInput(incomingObject);
            
            return accounts;
        }
    }

    public class AccountProgAuthPromiseDone extends AccountProgAuthBase implements Promise.Done
    {
        private string completed;
        public AccountProgAuthPromiseDone() {
            
        }

        public void done(Object incomingObject)
        {
            system.debug('incomingObject' + incomingObject);
            super.checkInput(incomingObject);

            Map<Id,Account> accountMap = new Map<Id,Account>(accounts);

            for(Id aId: accountMap.keySet())
            {
                system.debug('aId' +  aId);
                accountMap.put(aId, new Account(Id = aId, Updating_Program_Authorizations__c = false));
                system.debug('accountMap' + accountMap);
            }
            System.debug('Uncheck Updating_Program_Authorizations__c');
            database.update(accountMap.values());
            system.debug('accountMap' + accountMap.size());
            completed = 'completed';
        }
    }

    public class AccountProgAuthPromiseError extends AccountProgAuthBase implements Promise.Error
    {
        @TestVisible
        private String errorMessage;

        public AccountProgAuthPromiseError() {}
        // This is the main interface method that you must implement
        // note that it does have a return type, and in this case I'm using the
        // promise.serializableData type. This will pass the 'error occured' string to the done handler
        public Object error(Exception e) {
            //for now, just dump it to the logs
            system.debug('Error Handler received the following exception ' + e.getmessage() + '\n\n' + e.getStackTraceString());
            
            //Make the error available for testing.
            this.errorMessage = e.getMessage();
            //Alternatively, you could do any number of things with this exception like:
            // 1. retry the promise chain. For instance, if an external service returns a temp error, retry
            // 1a. Use the flow control object to cap the retry's
            // 2. log the error to a UI friendly reporting object or audit log
            // 3. Email the error report, and related objects to the affected users
            // 4. post something to chatter.
    
            return e;
        }
    }
}