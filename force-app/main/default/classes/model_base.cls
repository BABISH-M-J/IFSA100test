/*
	Class name: model_base
	Created by: Brock Barlow
	Created date: 9-7-2017

	Base class for model_* SObject wrapper classes. These classes are easily serialized to JSON and can be used
	by JavaScript and AngualarJS in Visualforce pages.
*/

public abstract class model_base {
	/* Public Properties */
	public Id recordId {get;set;}
	public String recordName {get;set;}
	public Boolean selectedInSearch {get;set;}
	public String sObjectName {get;set;}
	public Integer pHashCode
	{
		get
		{
			return this.hashCode();
		} 
	}
	/* Private variables */
	private static final Map<String, Integer> hashCodeMap = new Map<String, Integer>{'A' => 1*31, 'a' => 1*37, 'B' => 2*31, 'b' => 2*37, 'C' => 3*31, 'c' => 3*37, 'D' => 4*31, 'd' => 4*37, 'E' => 5*31, 'e' => 5*37,
    	'F' => 6*31, 'f' => 6*37, 'G' => 7*31, 'g' => 7*37, 'H' => 8*31, 'h' => 8*37, 'I' => 9*31, 'i' => 9*37, 'J' => 10*31, 'j' => 10*37, 'K' => 11*31, 'k' => 11*37,
    	'L' => 12*31,  'l' => 12*37, 'M' => 13*31, 'm' => 13*37, 'N' => 14*31, 'n' => 14*37, 'O' => 15*31, 'o' => 15*37, 'P' => 16*31, 'p' => 16*37, 'Q' => 17*31, 'q' => 17*37,
    	'R' => 18*31, 'r' => 18*37, 'S' => 19*31, 's' => 19*37, 'T' => 20*31, 't' => 20*37, 'U' => 21*31, 'u' => 21*37, 'V' => 22*31, 'v' => 22*37, 'W' => 23*31, 'w' => 23*37,
    	'X' => 24*31, 'x' => 24*37, 'Y' => 25*31, 'y' => 25*37, 'Z' => 26*31, 'z' => 26*37,  '0' => 0,  '1' => 1, '2' => 2,  '3' => 3,  '4' => 4, '5' => 5,  '6' => 6, '7' => 7,
    	'8' => 8, '9' => 9
	};

    /* Constructors */
	public model_base() {
		
	}

	
	/* Methods */
	//Implementation of hashCode so clases that extend model_base can be used in Set<T> and Map<T1, T2>
	public Integer hashCode()
	{
		if(this.recordId != null)
		{
			String rId = this.recordId;
			String lastSixOfID = rId.subString(rId.length() - 6);
			String result = '';
			Integer[] values = new Integer[lastSixOfID.length()];
			for(Integer i = 0; i < values.size(); i++)
			{
				values[i] = hashCodeMap.get(lastSixOfID.mid(i, 1));
			}
			for(Integer x: values)
			{
				result = result + x;
			}
			return Long.valueOf(result).IntValue() ^ 3;
		}
		return 0;
	}

	public void consoleErrorMessage(Exception ex)
	{
		system.debug('An error was caught in the model_* class for SObject: ' + this.sObjectName + ' see exception message below');
		system.debug('Message: ' + ex.getMessage());
		system.debug('Stack trace: ' + ex.getStackTraceString());
	}

	/* Abstract Methods */
	//Each class that extends this base class must implement it's own method for testing equality
    public abstract boolean equals(Object o);
    //Each class that extends this base class must have a method that sets the recordId and recordName
    private abstract void setBaseValues();

	public Object populateField(String fieldName, SObject o)
	{
		try {
			return o.get(fieldName);
		} catch (SObjectException e) {
			System.debug(LoggingLevel.WARN, String.format('SOQL query did not query object: {0} field: {1}', new List<Object>{o.getSObjectType().getDescribe().getName(), fieldName}));
			return null;
		}
	}
}