public without sharing class profileUpdate
{
	public void doProfileUpdate()
	{     
		try
		{
			String userId = ApexPages.currentPage().getParameters().get('userId');
			String profileId = ApexPages.currentPage().getParameters().get('profileId');
			update new User(Id=userId,ProfileId = profileId);
		}
		catch(Exception e)
		{
			System.debug('::::user profile not update'+e);
		}
	}
}