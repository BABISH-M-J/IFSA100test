/** **********************************************************
Name        : unitWrapper
Function    : This class is created to sort list of custom class(wrapper type).
Description : This Class can be used to sort a sObject List Other than Name
Author      : GAURAV SINGH Senior Software Developer Astrea It Services Pvt. Ltd. , Noida India.
Created On  : 6 Jun 2017
Modified On : 
*********************************************************** */

public class unitWrapper implements Comparable {
    public c2g__codaTransactionLineItem__c trans;                
    
    public unitWrapper (c2g__codaTransactionLineItem__c  t){
        trans=t;
    }
    //Create this method to compare     
    public Integer compareTo(Object compareTo) {
       
        unitWrapper compareToOppy = (unitWrapper)compareTo;   //get the passed record in campareToOppy      
        Integer returnValue = 0;           
        
        //Campare the value of variable based 
        if(trans.Date__c > compareToOppy.trans.date__c)
            returnValue=1;
        else 
            returnValue=-1;
             
        return returnValue;      
    }
    
}