/**
 * @description User Service Class
 * @author Brock Barlow
 */
global without sharing class userService implements Queueable
{
// An enumeration to tell service methods if a dml action is an Insert, Update, Delete.
/**
* @description Enum of Trigger Types
*/
public enum triggerType
{
	isInsert,isUpdate,isDelete
}
/**
* @description Enum of Operation Types
	*/
public enum imOperations
{
	createCSVAndDeleteIM,deleteSP,createWorkspaceDocs
}
// Properties
private Set<imOperations> opsToExecute {get;set;}
private List<Id> inactiveUserIds {get;set;}
private List<ContentWorkspaceDoc> contentWSDocs {get;set;}

// Constuctors
/**
* @description Basic Constructor - Instantiates the userService with a set of Operations that need to run.
* @param Set<imOperations> ops - The operations that will be executed in the execute method
*/
public userService(Set<imOperations> ops)
{
	this.opsToExecute = ops;
}
/**
* @description Constructor - Instantiates the userService with a set of Operations that need to run and the Ids of the user.
* @param Set<imOperations> ops - The operations that will be executed in the execute method
* @param List<Id> usersIdsToDeactivate - List of users records to be deactivated
	*/
public userService(Set<imOperations> ops, List<Id> usersIdsToDeactivate)
{
	this(ops);
	this.inactiveUserIds = usersIdsToDeactivate;
}
/**
* @description Constructor - Instantiates the userService with a set of Operations that need to run and the workspace docs to be created and the name of the workspace
* @param Set<imOperations> ops - The operations that will be executed in the execute method
* @param List<ContentWorkspaceDoc> docs - List of ContentWorkspaceDocs to be created
	*/
public userService(Set<imOperations> ops, List<ContentWorkspaceDoc> docs)
{
	this(ops);
	this.contentWSDocs = docs;
}

/**
* @description Queueable execute method
	*/
public void execute(QueueableContext context) 
{
	if(this.inactiveUserIds != null)
	{
		if(this.opsToExecute.contains(imOperations.createCSVAndDeleteIM))
			// Run the operation to create the CSV file and delete IM records
			userService.generateCSVandDeleteIM(this.inactiveUserIds);

		if(this.opsToExecute.contains(imOperations.deleteSP))
			// Run the operation to delete SP records
			userService.deleteSPRecords(this.inactiveUserIds);
	}
	if(this.opsToExecute.contains(imOperations.createWorkspaceDocs) && !this.contentWSDocs.isEmpty())
		userService.createContentWorkspaceDocs(this.contentWSDocs);
}
public static void setUserCreatedDateOnContact(List<User> newRecords)
{
	List<Contact> contacts = new List<Contact>();
	for(User u: newRecords)
	{
		if(u.ContactId != null)
		{
			Contact c = new Contact(Id = u.ContactId, User_Last_Login_Date__c = DateTime.now(), User_Created_Date__c = DateTime.now());
			contacts.add(c);
		}
	}
	sObjectBatchUpdater.batchUpdate(contacts, 200);
}
/**
* @description Method to delete SP and CSP records related to the deactivated user
*/
private static void deleteSPRecords(List<Id> inactiveUserIds)
{
	List<Support_Personnel__c> spRecordsToDelete = [SELECT Id FROM Support_Personnel__c WHERE IFSA_Staff__c IN: inactiveUserIds];

	sObjectBatchUpdater.batchUpdate(spRecordsToDelete, 10, sObjectBatchUpdater.dmlTypes.dmlDelete);
}
/**
* @description Method to generate CSV file of the deactivated users IM records and create a "File (ContentVersion/ContentDocument)" record and link with a ContentWorkspace using a ContentWorkspaceDoc record and then delete IM records
*/
private static void generateCSVandDeleteIM(List<Id> inactiveUserIds)
{
	// Get IM Records
	List<Incident_Matrix__c> imRecordsToDelete = [SELECT Id, IFSA_Staff__c, IFSA_Staff__r.Name , Incident_Category__c, Incident_Sub_Category__c, Incident_Sub_Subcategory__c, Severity__c, Support_Role_Type__c FROM Incident_Matrix__c WHERE IFSA_Staff__c IN: inactiveUserIds ORDER BY IFSA_Staff__c];
	// Create Map of IFSA Staff Id and IM Records
	Map<Id, List<Incident_Matrix__c>> imMap = new Map<Id, List<Incident_Matrix__c>>();
	for(Incident_Matrix__c im: imRecordsToDelete)
	{
		if(!imMap.containsKey(im.IFSA_Staff__c))
			imMap.put(im.IFSA_Staff__c, new List<Incident_Matrix__c>());
		imMap.get(im.IFSA_Staff__c).add(im);
	}
	// Create CSV file for each IFSA Staff
	List<ContentVersion> csvFiles = new List<ContentVersion>();
	for(Id userId: imMap.keySet())
	{
		ContentVersion userIM = new ContentVersion();
		// Constant strings used to build csv file
		String newLine = '\r\n';
		String c = ',';
		// Header row of CSV file
		String csv = 'IFSA_Staff__c, Incident_Category__c, Incident_Sub_Category__c, Incident_Sub_Subcategory__c, Severity__c, Support_Role_Type__c' + newLine;
		// Data rows of CSV file
		for(Incident_Matrix__c im: imMap.get(userId))
		{
			csv = csv + im.IFSA_Staff__c + c + im.Incident_Category__c + c + im.Incident_Sub_Category__c + c + im.Incident_Sub_Subcategory__c + c + im.Severity__c + c + im.Support_Role_Type__c + newLine;
		}
		// Build file Name
		String dayNumber = Date.today().day() > 9 ? Date.today().day().format() : '0' + Date.today().day().format();
		String monthNumber = Date.today().month() > 9 ? Date.today().month().format() : '0' + Date.today().month().format();
		userIM.Title = 'Incident Matrix Backup ' + imMap.get(userId).get(0).IFSA_Staff__r.Name+ ' ' + monthNumber + '_' + dayNumber + '_' + Date.today().year();
		// Set Content Version properties
		userIM.PathOnClient = '/'+userIM.Title+'.csv';
		userIM.TagCsv = userId;
		userIM.VersionData = Blob.valueOf(csv);
		// Add Content Version to list
		csvFiles.add(userIM);
	}
	Database.insert(csvFiles);
	// Link CSV files to User records
	String libName = !configurationManager.isTestMode() ? 'Deleted IM' : 'DeactivateTest_' + Math.roundToLong(Math.random()*99999);
	createContentWorkspaceDocs(new Map<Id, ContentVersion>(csvFiles), libName);

	// Delete IM Records
	sObjectBatchUpdater.batchUpdate(imRecordsToDelete, 200, sObjectBatchUpdater.dmlTypes.dmlDelete);
}

/**
* @description Method to link a file with the "Deleted IM" ContentWorkspace using a ContentWorkspaceDoc record and then delete IM records
* @param Map<Id, ContentVersion> mapCV - Map of the ContentVersion records that are to be linked to the library
* @param String libraryName - Name of the library to use. If the library does not exist, it will be created
*/
@TestVisible
private static void createContentWorkspaceDocs(Map<Id, ContentVersion> mapCV, String libraryName)
{
	// Blocks execution if the library name contains "DeactivateTest_". The method needs to be tested with "SeeAllData=true" to properly run.
	if(libraryName.contains('DeactivateTest_'))
		return;
	// Try to find the ContentWorkspace
	ContentWorkspace workspace = new ContentWorkspace();
	try
	{
		workspace = [SELECT Id FROM ContentWorkspace WHERE DeveloperName =: libraryName.replace(' ', '_')].get(0);
	}
	// Create ContentWorkspace if one does not exist
	catch(ListException e)
	{		
		workspace.Name = libraryName;
		workspace.DeveloperName = libraryName.replace(' ', '_');
		workspace.Description = libraryName +' Records';
		Database.insert(workspace);
	}
	// Get the newly ContentVersion records
	List<ContentVersion> csvFiles = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: mapCV.keySet()];
	List<ContentWorkspaceDoc> cwds = new List<ContentWorkspaceDoc>();
	// Create ContentWorkspaceDoc for each file created
	for(ContentVersion cv: csvFiles)
	{
		
		ContentWorkspaceDoc cwd = new ContentWorkspaceDoc();
		cwd.ContentDocumentId = cv.ContentDocumentId;
		cwd.ContentWorkspaceId = workspace.Id;
		cwds.add(cwd);
	}
	// Create a new instance of the service to create a queueable job to insert the records asynchronously
	userService us = new userService(new Set<userService.imOperations>{userService.imOperations.createWorkspaceDocs}, cwds);
	Id jobId = system.enqueueJob(us);
}
/**
* @description Method to insert the ContentWorkspaceDoc records
*/
private static void createContentWorkspaceDocs(List<ContentWorkspaceDoc> docs)
{
	Database.insert(docs);
}
/**
* @description Static method that instantiates a userService with a set of Operations that need to run and the Ids of the users to be deactivated.
* 				Filters out any community user records or internal user records that are not being deactivated
* @param Set<imOperations> ops - The operations that will be executed in the execute method
* @param Map<Id, User> newMap - Map of the newly updated user records
* @param Map<Id, User> oldMap - Map of the user records before the update
	*/
public static void deactivateUsers(Set<userService.imOperations> operations, Map<Id, User> newMap, Map<Id, User> oldMap)
{
	// Get community profile ids and names
	List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('IFSA Advisor User', 'IFSA Custom Student User', 'IFSA Student User')];
	List<Id> inactiveUserIds = new List<Id>();
	for(Id userId: newMap.keySet())
	{
		User newRecord = newMap.get(userId);
		User oldRecord = oldMap.get(userId);
		// Is the user being deactivated?
		if(!newRecord.IsActive && oldRecord.IsActive)
		{
			// Is the user a community user?
			Boolean isPortalUser = false;
			for(Profile p: profiles)
			{
				if(newRecord.ProfileId == p.Id)
					isPortalUser = true;
			}
			// Add userid to list if it is being deactivated and is not a portal user
			if(!isPortalUser)
				inactiveUserIds.add(userId);
		}
	}
	// Instantiates a userService to create IM csv, link it to deleted im library, delete im records and delete sp records
	if(!inactiveUserIds.isEmpty())
		Id jobId = system.enqueueJob(new userService(new Set<userService.imOperations>{userService.imOperations.createCSVAndDeleteIM, userService.imOperations.deleteSP}, inactiveUserIds));
}
/**
* @description Assigns Formstack Permission Set to new Student Portal Users
* @param List<User> newRecords - The newly inserted user records
*/
public without sharing class ifsaFormstackUtility implements Queueable
{
	List<User> userRecords = new List<User>();
	public ifsaFormstackUtility(Map<Id, User> newRecords)
	{
		this.userRecords = [SELECT Id, IsActive FROM User WHERE Profile.Name IN('IFSA Student User', 'IFSA CHART Student User') AND Id IN: newRecords.keySet()];
	}

	public void execute(QueueableContext context)
	{
		
		Id formstackPermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Fast_Forms_Permissions'].get(0).Id;
		List<PermissionSetAssignment> permissions = new List<PermissionSetAssignment>();

		for(User u: userRecords)
		{
			if(u.IsActive)
			{
				permissions.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = formstackPermissionSetId));
			}
		}

		if(!configurationManager.isTestMode())
		{
			Database.insert(permissions);
		}
	}
	
}

	public static void afterInsertIfsaMember(List<User> newRecords,
											Boolean bypassAfterInsert){
		//creating IFSA Team member on new User Creation
		List<IFSA_Team_Member__c> IFSAMemberToInsert = new List<IFSA_Team_Member__c>();
		Map<String, String> userIFSAMetadataMapping = new Map<String, String>();
		for(IFSATeamMemberMapping__mdt mdt : [SELECT UserLabel__c, IFSALabel__c FROM IFSATeamMemberMapping__mdt]){
			userIFSAMetadataMapping.put(mdt.UserLabel__c, mdt.IFSALabel__c);
		}

		for(User u : newRecords){
			if(!u.IsPortalEnabled){
				IFSA_Team_Member__c newIFSARec = new IFSA_Team_Member__c();
				for(String fieldToAdd : userIFSAMetadataMapping.keySet()){
					if(fieldToAdd == 'Name'){
						newIFSARec.put(userIFSAMetadataMapping.get(fieldToAdd), (u.get('FirstName') + ' ' + u.get('LastName')));
					}else{
						newIFSARec.put(userIFSAMetadataMapping.get(fieldToAdd), u.get(fieldToAdd));
					}
					newIFSARec.put('Employee_ID__c', u.get('Id'));
				}
				IFSAMemberToInsert.add(newIFSARec);
			}
		}

		if(!IFSAMemberToInsert.isEmpty()){
			insert IFSAMemberToInsert;
		}
		if (bypassAfterInsert) return;	
	}
	@future
	public static void afterUpdateIfsaMember(String newRecordsStr, String oldMapStr ){
		List<User> newRecords = new List<User>();
		Map<id,User> oldMap = new Map<id,User>();
		newRecords = (List<User>)System.JSON.deserialize(newRecordsStr, List<User>.class);
		System.debug('newRecordssss '+ newRecords);
		oldMap = (Map<id,User>)System.JSON.deserialize(oldMapStr, Map<id,User>.class);
		System.debug('oldMapppp '+ oldMap);
		Set<String> userNameSet = new Set<String>();
		List<IFSA_Team_Member__c> IFSAMemberToUpdate = new List<IFSA_Team_Member__c>();
		List<IFSA_Team_Member__c> IFSAMemberToInsert = new List<IFSA_Team_Member__c>();
		Map<String, IFSA_Team_Member__c> IFSATeamMembersMap = new Map<String, IFSA_Team_Member__c>();
		Map<String, String> userIFSAMetadataMapping = new Map<String, String>();
       
        for(IFSATeamMemberMapping__mdt mdt : [SELECT UserLabel__c, IFSALabel__c FROM IFSATeamMemberMapping__mdt]){
            userIFSAMetadataMapping.put(mdt.UserLabel__c, mdt.IFSALabel__c);
        }
       
        for(User u : newRecords){
            /*if(oldMap.containsKey(u.Id) && oldMap.get(u.Id).FullPhotoUrl != u.FullPhotoUrl){
                userNameSet.add(u.Id);
            }*/
           userNameSet.add(u.Id);
        }
       System.debug('userNameSet '+userNameSet);
        if(!userNameSet.isEmpty()){
           
            for(IFSA_Team_Member__c IFSATeam : [SELECT Name__c, Email__c, Employee_ID__c,Title__c FROM IFSA_Team_Member__c WHERE Employee_ID__c IN: userNameSet]){
                IFSATeamMembersMap.put(IFSATeam.Employee_ID__c, IFSATeam);
            }
           
            for(User u : newRecords){
				if(!u.IsPortalEnabled){
					IFSA_Team_Member__c newIFSARec = new IFSA_Team_Member__c();
					if(IFSATeamMembersMap.containsKey(u.Id)){
						newIFSARec = IFSATeamMembersMap.get(u.Id);
					
						for(String fieldToAdd : userIFSAMetadataMapping.keySet()){  
							if(fieldToAdd == 'Name'){
								if((u.get('FirstName') != oldMap.get(u.Id).get('FirstName')) || (u.get('LastName') != oldMap.get(u.Id).get('LastName'))){
									newIFSARec.put(userIFSAMetadataMapping.get(fieldToAdd), (u.get('FirstName') + ' ' + u.get('LastName')));
								}
							}
							else if(u.get(fieldToAdd) != oldMap.get(u.Id).get(fieldToAdd)){
								newIFSARec.put(userIFSAMetadataMapping.get(fieldToAdd), u.get(fieldToAdd));
							}
							
						}
						IFSAMemberToUpdate.add(newIFSARec);
					}else{
						for(String fieldToAdd : userIFSAMetadataMapping.keySet()){
							if(fieldToAdd == 'Name'){
								newIFSARec.put(userIFSAMetadataMapping.get(fieldToAdd), (u.get('FirstName') + ' ' + u.get('LastName')));
							}else{
								newIFSARec.put(userIFSAMetadataMapping.get(fieldToAdd), u.get(fieldToAdd));
							}
							newIFSARec.put('Employee_ID__c', u.get('Id'));
						}
						IFSAMemberToInsert.add(newIFSARec);
					}
				}               
            }
        }
        system.debug('IFSAMemberToUpdatelast='+IFSAMemberToUpdate);
        if(!IFSAMemberToUpdate.isEmpty()){      
            update IFSAMemberToUpdate;
        }
        system.debug('IFSAMemberToInsertlast='+IFSAMemberToInsert);
        if(!IFSAMemberToInsert.isEmpty()){
          insert IFSAMemberToInsert;
        }
	}
}