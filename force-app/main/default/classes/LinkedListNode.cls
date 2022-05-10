/**
 * LinkedListNode - Written by Jacob Schultz 13.4.16
 * 
 * A simple node class used by the Apex Linked List class.
 * This node will hold any SObject (User, Opp, Case, Etc.)
 * It will also hold a value/weight/index - whatever int you would like
 * Since the LinkedList is a doubly linkedlist there are also fields
 * for the next and previous node.
 * 
 */
public class LinkedListNode {
    
    private SObject obj;
    private Integer value;
    private Id idValue;
    private LinkedListNode previous; 
    private LinkedListNode next;
    
    public LinkedListNode(){
        this.obj = null;
        this.value = 0;
        this.previous = null;
        this.next = null;
    }
    
    public LinkedListNode(SObject obj, Integer value, Id idValue){
        this.obj = obj;
        this.value = value;
        this.idValue = idValue;
    }
    
    public SObject getObject(){
        return this.obj; 
    }
    
    public Integer getValue(){
        return this.value;
    }
    
    public Id getIdValue(){
        return this.idValue;
    }

    public void setObject(SObject obj){
        this.obj = obj;
    }
    
    public void setValue(Integer i){
        this.value = i;
    }
    public void setIdValue(Id i){
        this.idValue = i;
    }
    
    public void setNext(LinkedListNode n){
        this.next = n;
    }
    
    public void setPrevious(LinkedListNode p){
        this.previous = p;
    }
    
    public LinkedListNode getPrevious(){
        return this.previous;
    }
    
    public LinkedListNode getNext(){
        return this.next;
    }
}