/**
 * Deletes student favorite records that are older than 4 years
 * @author Jay Holt
 */
// ApexDoc updated 2/1/2021 Brock Barlow
global class deleteFavoritesSchedulable implements Schedulable {
    /**
     * Execute method required by Schedulable interface
     */
    global void execute(SchedulableContext ctx) {
        deleteFavoritesSchedulable.deleteOldFavs();
    }
    /**
     * Deletes student favorite records older than 4 years.
     */
    public static void deleteOldFavs(){
        // Four years ago from today
        DateTime fya = DateTime.now().addYears(-4);
        
        List<Favorite__c> favsToDelete = [
            SELECT Id
            FROM Favorite__c
            WHERE CreatedDate <= :fya AND Contact__r.RecordType.Name LIKE '%Student%'
        ];

        sObjectBatchUpdater.batchUpdate(favsToDelete, 200, sObjectBatchUpdater.dmlTypes.dmlDelete);
    }
}