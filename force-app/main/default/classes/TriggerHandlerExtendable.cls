public interface TriggerHandlerExtendable 
{
    void beforeInsert();

    void beforeUpdate();

    void beforeDelete();
    
    void beforeUndelete();

    void afterInsert();

    void afterUpdate();

    void afterDelete();

    void afterUndelete();
}