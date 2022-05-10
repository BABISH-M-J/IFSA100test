/**
 * @description Updates Top 25 Checkboxes on courses on scheduled day.
 */
public without sharing class scheduledPopularClassUpdater implements Schedulable {

    public void execute(SchedulableContext SC) {
        updatePopularClasses(Date.today());
    }

    public static void manuallyCalculateCoursePopulatity(String ternName)
    {
        switch on ternName {
            when 'Fall'{
                scheduledPopularClassUpdater.updatePopularClasses(date.newInstance(Date.today().year(), 1, 1));
            }
            when 'Spring'{
                scheduledPopularClassUpdater.updatePopularClasses(date.newInstance(Date.today().year(), 6, 1));
            }
            when 'Summer'{
                scheduledPopularClassUpdater.updatePopularClasses(date.newInstance(Date.today().year(), 12, 1));
            }
        }
    }

    @testVisible
    private static void updatePopularClasses(Date today)
    {
        String term;
        List<Integer> years;
        // Calculate Summer on June 1 of any given year
        if(today.day() == 1 && today.month() == 6)
        {
            System.debug('Updating popular classes for "Spring"');
            term = 'Spring';
            years = new List<Integer>{today.year(), today.year() - 1, today.year() - 2};
        }
        // Calculate Fall on Jan 1 of any given year
        else if(today.day() == 1 && today.month() == 1)
        {
            System.debug('Updating popular classes for "Fall"');
            term = 'Fall';
            years = new List<Integer>{today.year() - 1, today.year() - 2, today.year() - 3};
        }
        // Calculate Summer on Dec 1 of any given year
        else if(today.day() == 1 && today.month() == 12)
        {
            System.debug('Updating popular classes for "Summer"');
            term = 'Summer';
            years = new List<Integer>{today.year() - 1, today.year() - 2, today.year() - 3};
        }

        if(term != null && years != null)
        {
            for(Country__c c: [SELECT Id FROM Country__c WHERE Active__c = TRUE])
            {
                System.enqueueJob(new popularClassQueueable(c.Id, term, years));
            }
        }
        else
        {
            System.debug('It is not the correct day to update popular classes');
        }
    }

    public class popularClassQueueable implements Queueable
    {
        private Id countryId {get; set;}
        private String term {get; set;}
        private List<Integer> years {get; set;}

        public popularClassQueueable(Id c, String t, List<Integer> y){
            this.countryId = c;
            this.term = t;
            this.years = y;
        }

        public void execute(QueueableContext context) {
            AggregateResult[] courseRegs = [SELECT Course__c courseId, Application__r.Program_Term__r.Program__r.Name program, COUNT(Id) regCount 
                        FROM Course_Registration__c 
                        WHERE Status__c IN ('Approval Pending', 'Approved', 'Grade Entered', 'Grade Verified', 'Grade Submitted', 'Grade Corrected', 'Grade Revised', 'Ready for Butler') 
                            AND Course__r.Approved_For_CHART__c = TRUE
                            AND Course_Term__c =: term 
                            AND Application__r.Program_Term__r.Term__r.Year__c IN: years
                            AND Application__r.Program_Term__r.Program__r.Category__c = 'Catalog'
                            AND Application__r.Program_Term__r.Country__c =: countryId
                            AND Course__r.Is_Expired__c = FALSE
                        GROUP BY Application__r.Program_Term__r.Program__r.Name, Course__c 
                        ORDER BY Application__r.Program_Term__r.Program__r.Name, COUNT(Id) DESC
                        LIMIT 2000];
            Map<String, List<Id>> progIdCourseIdMap = new Map<String, List<Id>>();
            for(AggregateResult ar: courseRegs)
            {
                String programName = (String) ar.get('program');
                Integer regCount = (Integer) ar.get('regCount');
                Id courseId = (Id) ar.get('courseId');
                if(!progIdCourseIdMap.containsKey(programName))
                {
                    progIdCourseIdMap.put(programName, new List<Id>());
                }
                
                if(progIdCourseIdMap.get(programName).size() < 25 && regCount > 2 && courseId != null)
                {
                    progIdCourseIdMap.get(programName).add(courseId);
                }
            }

            Map<Id, Course__c> popularCourses = new Map<Id, Course__c>();
            for(String programName: progIdCourseIdMap.keySet())
            {
                List<Id> courseIds = progIdCourseIdMap.get(programName);
                if(!courseIds.isEmpty())
                {
                    System.debug(programName + ': ' + courseIds.size());
                }
                
                for(Id courseId: courseIds)
                {
                    Course__c popularCourse = new Course__c(Id = courseId);
                    switch on term {
                        when 'Fall'{
                            popularCourse.Is_Top_25_Fall__c = true;
                        }
                        when 'Spring'{
                            popularCourse.Is_Top_25_Spring__c = true;
                        }
                        when 'Summer'{
                            popularCourse.Is_Top_25_Summer__c = true;
                        }
                    }
                    popularCourses.put(popularCourse.Id, popularCourse);
                }
            }
            // Get classes that where popular but are no longer popular for the specified term and update
            List<Course__c> noLongerPopularCourses;
            switch on term {
                when 'Fall'{
                    noLongerPopularCourses = [SELECT Id FROM Course__c WHERE Host_Institution__r.Country__c =: countryId AND Is_Top_25_Fall__c = TRUE AND (NOT(Id IN: popularCourses.keySet()))];
                }
                when 'Spring'{
                    noLongerPopularCourses = [SELECT Id FROM Course__c WHERE Host_Institution__r.Country__c =: countryId AND Is_Top_25_Spring__c = TRUE AND (NOT(Id IN: popularCourses.keySet()))];
                }
                when 'Summer'{
                    noLongerPopularCourses = [SELECT Id FROM Course__c WHERE Host_Institution__r.Country__c =: countryId AND Is_Top_25_Summer__c = TRUE AND (NOT(Id IN: popularCourses.keySet()))];
                }
            }
            
            for(Course__c notPopularCourse: noLongerPopularCourses)
            {
                switch on term {
                    when 'Fall'{
                        notPopularCourse.Is_Top_25_Fall__c = false;
                    }
                    when 'Spring'{
                        notPopularCourse.Is_Top_25_Spring__c = false;
                    }
                    when 'Summer'{
                        notPopularCourse.Is_Top_25_Summer__c = false;
                    }
                }
            }
            
            // Batch Update Popular Classes
            sObjectBatchUpdater.batchUpdate(new List<Course__c>(popularCourses.values()), 200, sObjectBatchUpdater.dmlTypes.dmlUpdate);
            // Batch Update No Longer Popular Classes
            sObjectBatchUpdater.batchUpdate(noLongerPopularCourses, 200, sObjectBatchUpdater.dmlTypes.dmlUpdate);
        }
    }
}