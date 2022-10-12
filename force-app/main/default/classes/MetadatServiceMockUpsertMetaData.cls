@isTest
public class MetadatServiceMockUpsertMetaData implements WebServiceMock{
	public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) 
    {
        List<MetadataService.Error> errorList = new List<MetadataService.Error>();
        MetadataService.Error errorRecord1 = new MetadataService.Error();
        errorRecord1.statusCode = '400';
        errorList.add(errorRecord1);
        MetadataService.Error errorRecord2 = new MetadataService.Error();
        errorRecord1.statusCode = '500';
        errorList.add(errorRecord2);
        
        List<MetadataService.UpsertResult> result = new List<MetadataService.UpsertResult>();
        MetadataService.UpsertResult upsertResultRecord1 = new MetadataService.UpsertResult();
        MetadataService.UpsertResult upsertResultRecord2 = new MetadataService.UpsertResult();
        result.add(upsertResultRecord1);
        result.add(upsertResultRecord2);
        result[0].success = true;
        result[1].success = false;
        result[1].errors = errorList;
        
        MetadataService.upsertMetadataResponse_element r = new MetadataService.upsertMetadataResponse_element();
        r.result = result;
        response.put('response_x', r);  
    }

}