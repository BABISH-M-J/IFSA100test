/**
 * @description Model class used to describe a case team member
 * @author Brock Barlow
 */
public with sharing class model_CaseTeamMember extends model_base
{
	public String caseId {get;set;}
	public String memberRole {get;set;}
	public String caseAccess {get;set;}
	public Boolean visibleInPortal {get;set;}
	public DateTime createdDateTime {get;set;}
	public DateTime modifiedDateTime {get;set;}
	public model_User modifiedBy {get;set;}
	public model_User member {get;set;}

	public model_CaseTeamMember()
	{
		
	}
	public model_CaseTeamMember(CaseTeamMember teamMember)
	{
		this.recordId = teamMember.Id;
		this.caseId = teamMember.ParentId;
		this.memberRole = teamMember.TeamRole.Name;
		this.caseAccess = teamMember.TeamRole.accesslevel;
		this.createdDateTime = teamMember.CreatedDate;
		this.member = new model_User(teamMember.memberId, teamMember.member.FirstName, teamMember.member.LastName, teamMember.member.email);		
		this.setBaseValues();
	}
	private void setBaseValues()
	{
		//this.recordId = this.localityId;
		//this.recordName = this.name;
		this.sObjectName = 'CaseTeamMember';
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_CaseTeamMember)
		{
			model_CaseTeamMember obj = (model_CaseTeamMember)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}