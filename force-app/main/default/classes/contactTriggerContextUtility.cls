/**
 * This class is used in ensuring that contactTrigger only is executed once during an operation
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public with sharing class contactTriggerContextUtility {

    private static boolean firstRun = true;
    private static boolean isAfter = false;

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
   		label='Reset Contact isFirstRun'
   		description='Resets isFirstRun after trigger has run')
    public static void resetIsFirstRun () {
    	firstRun = true;
    }
}