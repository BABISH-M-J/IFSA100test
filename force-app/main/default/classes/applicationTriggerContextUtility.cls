/**
 * This class is used in ensuring that applicationTrigger only is executed once during an operation
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public with sharing class applicationTriggerContextUtility {

    private static boolean firstRun = true;
    private static boolean isAfter = false;
    // added - powerfluence - application items not generated - 001 - starts
    private static boolean requestedPopulateApplicationItems = false;
    // added - powerfluence - application items not generated - 001 - ends
    /**
     * Return the value of firstRun
     */
    public static boolean isFirstRun() {
        return firstRun;
    }
    /**
     * Returns true if firstRun == false and isAfter == true
     */
    public static boolean isFirstRunAndAfter() {
    	return !firstRun && isAfter ? true : false;
    }
    /**
     * Sets firstRun to false
     */
    public static void setFirstRunFalse(){
        firstRun = false;
    }
    /**
     * Sets isAfter to true
     */
    public static void setIsAfterTrue() {
    	isAfter = true;
    }
    /**
     * Invocable method used by Lightning process to reset this class
     */
    @InvocableMethod(
   		label='Reset Application isFirstRun'
   		description='Resets isFirstRun after trigger has run')
    public static void resetIsFirstRun () {
    	firstRun = true;
    	isAfter = false;
    }
    // added - powerfluence - application items not generated - 002 - starts
    /**
     * Sets requestedPopulateApplicationItems to false
     */
    public static void setRequestedPopulateApplicationItems(Boolean value){
        requestedPopulateApplicationItems = value;
    }
    /**
     * Gets value stored in requestedPopulateApplicationItems
     */
    public static boolean isRequestedPopulateApplicationItems(){
        return requestedPopulateApplicationItems;
    }
    // added - powerfluence - application items not generated - 002 - ends
}