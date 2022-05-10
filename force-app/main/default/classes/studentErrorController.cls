public without sharing class studentErrorController 
{
    public String gaId {get;set;}
    public String gtmId {get;set;}
    public studentErrorController() 
    {
        GoogleAnalyticsUtility util = new GoogleAnalyticsUtility('SP');
        this.gaId = util.getAnalyticsId();
        this.gtmId = util.getTagManagerId();
    }
}