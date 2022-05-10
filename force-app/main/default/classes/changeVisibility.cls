public class changeVisibility {
    
    public void updateVisibility(List<ContentVersion> cv ){
        Set<Id> cvSet=new Set<Id>();
        List<ContentDocumentLink> cdlList=new List<ContentDocumentLink>();
        for(ContentVersion c:cv)
        {
         cvSet.add(c.ContentDocumentId);
        }
        System.debug('changing the visibility......');
        for(ContentDocumentLink cdl:[Select Id, visibility from ContentDocumentLink where ContentDocumentId in: cvSet])
        {
          
                cdl.Visibility='AllUsers';
                cdlList.add(cdl);
            
        }
        system.debug(cdlList);
       update cdlList;
    }
}