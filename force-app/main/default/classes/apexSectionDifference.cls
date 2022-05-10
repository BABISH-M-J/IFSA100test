/**
 * Utility class to be used to determine what sections have been added or removed. This is used with Billing_Arrangement__c and Program_Authorization__c
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public class apexSectionDifference
{
    private Set<String> addedSectionsSet {get; set;}
    private Set<String> removedSectionsSet {get; set;}

    /**
     * apexSectionDifference Constuctor, basic
    */
    public apexSectionDifference()
    {
        addedSectionsSet = new Set<String>();
        removedSectionsSet = new Set<String>();
    }

    /**
     * apexSectionDifference Constuctor, provides two strings to compare for differences. This constuctor populates the two private Set<String> properties on this class
     * @param currentSections The current sections from the Term__c multi-select picklist
     * @param previousSections The previous sections from the Term__c multi-select picklist
     */
    public apexSectionDifference(String currentSections, String previousSections)
    {
        this();
        String[] cSectionsArray;
        String[] pSectionsArray;
        if(currentSections != null)
        {
            cSectionsArray = currentSections.split(';');
            for(String cSectionName: cSectionsArray)
            {
                if(!previousSections.contains(cSectionName))
                {
                    this.addToAdded(cSectionName);
                }
                
            }
        }
        else
        {
            currentSections = '';
        }
        if(previousSections != null)
        {
            pSectionsArray = previousSections.split(';');
            for(String pSectionName: pSectionsArray)
            {
                if(!currentSections.contains(pSectionName))	
                {
                    this.addToRemoved(pSectionName);
                }
            }
        }
        else
        {
            previousSections = '';
        }
    }
    /**
     * Adds a section to addedSectionSet
     * @param String - the name of the section to add
    */
    public void addToAdded(String sectionName)
    {
        addedSectionsSet.add(sectionName);
    }
    /**
     * Adds a section to removedSectionsSet
     * @param String - the name of the section to add
    */
    public void addToRemoved(String sectionName)
    {
        removedSectionsSet.add(sectionName);
    }
    /**
     * Determines if the two sets of Strings are equal
     * @return Boolean
    */
    public Boolean hasNoDifference()
    {
        // Convert Set<String> to List<String> for sort()
        List<String> added = new List<String>(addedSectionsSet);
        List<String> removed = new List<String>(removedSectionsSet);
        added.sort();
        removed.sort();
        // Determine Equality
        return added == removed;
    }
    /**
     * gets the Added Sections in a String
     * @return String - Added sections names separated by ","
    */
    public String addedSections()
    {
        return sections(addedSectionsSet);
    }
    /**
     * gets the Removed Sections in a String
     * @return String - Removed sections names separated by ","
    */
    public String removedSections()
    {
        return sections(removedSectionsSet);
    }
    /**
     * Iterates over Set<String> of section names to create a String of section names separted by ","
     * @param Set<String> Section Names
     * @return String - Sections names separated by ","
    */
    private String sections(Set<String> sectionSet)
    {
        String value = '';
        for(String s: sectionSet)
        {
            value = value.length() > 0 ? value + ',' + s : s;
        }
        return value;
    }
}