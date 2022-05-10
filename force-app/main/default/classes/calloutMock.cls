public class calloutMock implements HttpCalloutMock{
      public HTTPResponse respond(HTTPRequest req) {
         
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('Target URL');
        res.setStatusCode(200);
        System.assertEquals('POST', req.getMethod());
      
        return res;
    }        
    
}