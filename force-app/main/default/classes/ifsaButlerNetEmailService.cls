//Generated by wsdl2apex

public class ifsaButlerNetEmailService {
    public class ArrayOfstring {
        public String[] string_x;
        private String[] string_x_type_info = new String[]{'string','http://schemas.microsoft.com/2003/10/Serialization/Arrays',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://schemas.microsoft.com/2003/10/Serialization/Arrays','true','false'};
        private String[] field_order_type_info = new String[]{'string_x'};
    }
    public class Create_element {
        public String Identity;
        public String StudentFirstName;
        public String StudentLastName;
        public String ForwardingAddress;
        public String ContactId;
        private String[] Identity_type_info = new String[]{'Identity','http://tempuri.org/',null,'0','1','true'};
        private String[] StudentFirstName_type_info = new String[]{'StudentFirstName','http://tempuri.org/',null,'0','1','true'};
        private String[] StudentLastName_type_info = new String[]{'StudentLastName','http://tempuri.org/',null,'0','1','true'};
        private String[] ForwardingAddress_type_info = new String[]{'ForwardingAddress','http://tempuri.org/',null,'0','1','true'};
        private String[] ContactId_type_info = new String[]{'ContactId','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'Identity','StudentFirstName','StudentLastName','ForwardingAddress','ContactId'};
    }
    public class CreateResponse_element {
        public ifsaButlerNetEmailService.ArrayOfstring CreateResult;
        private String[] CreateResult_type_info = new String[]{'CreateResult','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'CreateResult'};
    }
    public class Delete_element {
        public String Identity;
        public String StudentEmailAddress;
        public String ContactId;
        private String[] Identity_type_info = new String[]{'Identity','http://tempuri.org/',null,'0','1','true'};
        private String[] StudentEmailAddress_type_info = new String[]{'StudentEmailAddress','http://tempuri.org/',null,'0','1','true'};
        private String[] ContactId_type_info = new String[]{'ContactId','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'Identity','StudentEmailAddress','ContactId'};
    }
    public class Edit_element {
        public String Identity;
        public String StudentEmailAddress;
        public String ForwardingAddress;
        public String ContactId;
        private String[] Identity_type_info = new String[]{'Identity','http://tempuri.org/',null,'0','1','true'};
        private String[] StudentEmailAddress_type_info = new String[]{'StudentEmailAddress','http://tempuri.org/',null,'0','1','true'};
        private String[] ForwardingAddress_type_info = new String[]{'ForwardingAddress','http://tempuri.org/',null,'0','1','true'};
        private String[] ContactId_type_info = new String[]{'ContactId','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'Identity','StudentEmailAddress','ForwardingAddress','ContactId'};
    }
    public class EditResponse_element {
        public ifsaButlerNetEmailService.ArrayOfstring EditResult;
        private String[] EditResult_type_info = new String[]{'EditResult','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'EditResult'};
    }
    public class DeleteResponse_element {
        public ifsaButlerNetEmailService.ArrayOfstring DeleteResult;
        private String[] DeleteResult_type_info = new String[]{'DeleteResult','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'DeleteResult'};
    }
    public class BasicHttpBinding_IStudentEmail {
        public String endpoint_x = 'http://hawkeye.eastus.cloudapp.azure.com/StudentEmail.svc';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'ifsaButlerNetEmailService', 'http://tempuri.org/', 'ifsaButlerNetEmailService'};
        public ifsaButlerNetEmailService.ArrayOfstring Delete_x(String Identity,String StudentEmailAddress,String ContactId) {
            ifsaButlerNetEmailService.Delete_element request_x = new ifsaButlerNetEmailService.Delete_element();
            request_x.Identity = Identity;
            request_x.StudentEmailAddress = StudentEmailAddress;
            request_x.ContactId = ContactId;
            ifsaButlerNetEmailService.DeleteResponse_element response_x;
            Map<String, ifsaButlerNetEmailService.DeleteResponse_element> response_map_x = new Map<String, ifsaButlerNetEmailService.DeleteResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/IStudentEmail/Delete',
              'http://tempuri.org/',
              'Delete',
              'http://tempuri.org/',
              'DeleteResponse',
              'ifsaButlerNetEmailService.DeleteResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.DeleteResult;
        }
        public ifsaButlerNetEmailService.ArrayOfstring Create(String Identity,String StudentFirstName,String StudentLastName,String ForwardingAddress,String ContactId) {
            ifsaButlerNetEmailService.Create_element request_x = new ifsaButlerNetEmailService.Create_element();
            request_x.Identity = Identity;
            request_x.StudentFirstName = StudentFirstName;
            request_x.StudentLastName = StudentLastName;
            request_x.ForwardingAddress = ForwardingAddress;
            request_x.ContactId = ContactId;
            ifsaButlerNetEmailService.CreateResponse_element response_x;
            Map<String, ifsaButlerNetEmailService.CreateResponse_element> response_map_x = new Map<String, ifsaButlerNetEmailService.CreateResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/IStudentEmail/Create',
              'http://tempuri.org/',
              'Create',
              'http://tempuri.org/',
              'CreateResponse',
              'ifsaButlerNetEmailService.CreateResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.CreateResult;
        }
        public ifsaButlerNetEmailService.ArrayOfstring Edit(String Identity,String StudentEmailAddress,String ForwardingAddress,String ContactId) {
            ifsaButlerNetEmailService.Edit_element request_x = new ifsaButlerNetEmailService.Edit_element();
            request_x.Identity = Identity;
            request_x.StudentEmailAddress = StudentEmailAddress;
            request_x.ForwardingAddress = ForwardingAddress;
            request_x.ContactId = ContactId;
            ifsaButlerNetEmailService.EditResponse_element response_x;
            Map<String, ifsaButlerNetEmailService.EditResponse_element> response_map_x = new Map<String, ifsaButlerNetEmailService.EditResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/IStudentEmail/Edit',
              'http://tempuri.org/',
              'Edit',
              'http://tempuri.org/',
              'EditResponse',
              'ifsaButlerNetEmailService.EditResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.EditResult;
        }
    }
}