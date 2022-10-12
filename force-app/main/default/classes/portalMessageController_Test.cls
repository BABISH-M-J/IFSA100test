@isTest
public class portalMessageController_Test {
    @isTest
    public static void testportalMessageController(){
        portalMessageController pmc = new portalMessageController();
        System.assertEquals(pmc.viewModel.isLockDownActive, false);
    }
}