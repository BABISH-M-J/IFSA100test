global class JSONGenerator {
    public static void generateForCMS(List<CMS__c> cmsList, String DMLType){
        system.debug('In JSONGenerator method');
        List<Record_Data> RecordData = new List<Record_Data>();
        /*List<CMS__c> cmsList = new List<CMS__c>();   
        cmsList = [SELECT Id, Program_Name__c,Active__c,RecordTypeId FROM CMS__c WHERE Id in :cmsSet];*/
        for(CMS__c cmsObj : cmsList){
            RecordData.add(new Record_Data((String)cmsObj.get('Program_Name__c'), (String)cmsObj.get('Id'), 'CMS__c',(Boolean)cmsObj.get('Active__c'),DMLType));
        }
        
        if(!RecordData.isEmpty()){
            String jsonSerial = '{"Record Data":'+JSON.serialize(RecordData)+'}';
            system.debug('jsonSerial--'+jsonSerial); 
            makeCallout(jsonSerial);
        }
        
    }
    
    @future(callout=true)
    public static void makeCallout(String jsonSerial){
        WordPress_Setting__c connDetails = WordPress_Setting__c.getInstance('WordPress');
       
        if(connDetails != null){
            HttpRequest req = new HttpRequest();
            req.setHeader('Authkey',connDetails.Authkey__c);
            req.setHeader('Content-Type', 'application/json');
            String endpoint = connDetails.EndPoint__c;
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setbody(jsonSerial);
            Http http = new Http();
            HTTPResponse response = http.send(req);
            System.debug(response.getBody());
        }
    }
    
    public class Record_Data {
        
        public String record_title;
        public String record_sf_id;
        public String record_type;
        public Boolean record_status;
        public String record_method;
        
        public Record_Data(String record_title, String record_sf_id, String record_type,Boolean record_status,String record_method){
            this.record_title  = record_title;
            this.record_sf_id  = record_sf_id;
            this.record_type   = record_type;
            this.record_status = record_status;
            this.record_method = record_method;
            
        }
    }  
}