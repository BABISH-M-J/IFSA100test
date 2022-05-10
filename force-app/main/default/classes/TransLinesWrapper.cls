public class TransLinesWrapper {
    
    public String dueDate{get;set;}
    public List<StatusGroup.StatusWrapper> groupStatus{get;set;} 
    
    public TransLinesWrapper(String due,List<StatusGroup.StatusWrapper> sw){
        dueDate = due;
        groupStatus = sw;
    }
}