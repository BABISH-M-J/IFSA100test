@isTest
public class LinkedListNodeTest {
 @TestSetup
    public static void mockData(){
    
            Account acct = apexMockDataUtility.createAccount('TestAcct');

    }
  @isTest 
    public static void testmodel(){
    
    Account a=[Select Id from Account limit 1];
    test.startTest();
       LinkedListNode l= new LinkedListNode();
       LinkedListNode l1=new LinkedListNode((SObject)a, 5, a.Id);
       SObject s= l1.getObject();
       System.assert(s==(SObject)a);
       Integer m=l1.getValue();
       System.assert(m==5);
       Id id1=l1.getIdValue();
       System.assert(id1==a.Id); 
       
       l1.setObject((SObject)a);
       l1.setValue(5);
       l1.setIdValue(a.Id);
       l1.setNext(l1);
       l1.setPrevious(l1);
       l1.getPrevious();
       l1.getNext();

        test.stopTest();
    }
}