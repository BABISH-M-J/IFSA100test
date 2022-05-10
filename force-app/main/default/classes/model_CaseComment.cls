/**
 * @description Model class used to describe a case comment
 * @author Brock Barlow
 */
public with sharing class model_CaseComment 
{
	public String commentId {get;set;}
	public String commentText {get;set;}
	public String caseId {get;set;}
	public Boolean isPublic {get;set;}
	public Boolean notify {get;set;}
	public DateTime createdDateTime {get;set;}
	public model_User createdBy {get;set;}
	public DateTime lastModifiedDateTime {get;set;}
	public model_User lastModifiedBy {get;set;}

	public model_CaseComment() 
	{
		
	}

	public model_CaseComment(String commentId)
	{
		buildFromRecord((CaseComment) apexQueryUtility.selectAllFrom('CaseComment', 'CreatedBy.FirstName, CreatedBy.LastName, LastModifiedBy.FirstName, LastModifiedBy.LastName', 'Id = \'' + commentId + '\'').get(0));
		
	}
	public model_CaseComment(CaseComment comment)
	{
		buildFromRecord(comment);
	}

	private void buildFromRecord(CaseComment thisComment)
	{

		this.commentId = commentId;
		this.commentText = thisComment.CommentBody;
		this.caseId = thisComment.ParentId;
		this.isPublic = thisComment.IsPublished;
		this.createdDateTime = thisComment.createddate;
		this.createdBy = new model_User(thisComment.createdById, thisComment.CreatedBy.FirstName, thisComment.CreatedBy.LastName);
		this.lastModifiedDateTime = thisComment.lastmodifieddate;
		this.lastModifiedBy = new model_User(thisComment.lastModifiedById, thisComment.lastModifiedBy.FirstName, thisComment.lastModifiedBy.LastName);
	}

	public Boolean saveComment()
	{
		CaseComment newComment = new CaseComment();
		newComment.IsPublished = this.isPublic == true ? true : false;
		newComment.CommentBody = this.commentText;
		newComment.ParentId = this.caseId;

		Database.SaveResult result = database.insert(newComment);

		return result.isSuccess();
	}	
}