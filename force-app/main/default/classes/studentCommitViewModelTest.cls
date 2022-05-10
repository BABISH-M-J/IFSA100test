//Created by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
@isTest
public with sharing class studentCommitViewModelTest {
  @isTest
    public static void studentCommitViewModelTestMethod() {
		Test.startTest();
        studentCommitViewModel scvm = new studentCommitViewModel();
        String appName = scvm.applicationName;
        String accConds = scvm.acceptanceConditions;
        List<studentApplyItemViewModel> appItems = scvm.appItems;
		Test.stopTest();
    }
}
//Created by PowerFluence req_dt:03/29/2022 ref email from Clayton ends