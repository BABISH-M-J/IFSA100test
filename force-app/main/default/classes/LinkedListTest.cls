@isTest
public class LinkedListTest {
 @TestSetup
    public static void mockData(){
    
            Account acct = apexMockDataUtility.createAccount('TestAcct');

    }
  @isTest 
    public static void testmodel(){
    
    Account a=[Select Id from Account limit 1];
    test.startTest();
       LinkedList l= new LinkedList();
        Boolean st1=l.isEmpty();
         System.assert(st1==true);
       l.addToList((SObject )a, 5, a.Id);
       l.deleteAtIndex(4);
     
         l.addToList((SObject )a, 3, a.Id);
       l.addInOrder((SObject )a, 4, a.Id);
        l.addInOrder((SObject )a, 2, a.Id);
       l.debugList();
       Integer s=l.getSize();
       System.assert(s==4);
      List<SObject> sList= l.convertToList();
      System.debug(sList);
      System.assert(sList[0]==a);
       List<SObject>sList1=l.convertToListDesc();
             System.debug(sList1);
 
       l.bubbleSort();
       Boolean st=l.isEmpty();
       System.assert(st==false);
            //  l.deleteAtIndex(3);

        test.stopTest();
    }
    @isTest 
    public static void testmodel1(){
     Account a=[Select Id from Account limit 1];
    test.startTest();
       LinkedList l= new LinkedList();
       l.addInOrder((SObject )a, 4, a.Id);
        Integer s=l.getSize();
       System.assert(s==1);
      l.addInOrder((SObject )a, 6, a.Id); 
      l.addInOrder((SObject )a, 5, a.Id); 
      l.deleteAtIndex(3);
       test.stopTest();
    }
    
}