/**
 * Unit test class for <<apexTextUtility>>
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
public with sharing class apexTextUtilityTest 
{
	/**
	 * Tests <<apexTextUtility>>.removeDiacritics
	 */
	public static testMethod void testRemoveDiacritics()	
	{
		String testString = 'ÁáÀàÂâǍǎĂăÃãẢảẠạÄäÅåĀāĄąẤấẦầẪẫẨẩẬậẮắẰằẴẵẲẳẶặǺǻĆćĈĉČčĊċÇçĎďĐđÐÉéÈèÊêĚěĔĕẼẽẺẻĖėËëĒēĘęẾếỀềỄễỂểẸẹỆệĞğĜĝĠġĢģĤĥĦħÍíÌìĬĭÎîǏǐÏïĨĩĮįĪīỈỉỊịĴĵĶķĹĺĽľĻļŁłĿŀŃńŇňÑñŅņÓóÒòŎŏÔôỐốỒồỖỗỔổǑǒÖöŐőÕõØøǾǿŌōỎỏƠơỚớỜờỠỡỞởỢợỌọỘộṔṕṖṗŔŕŘřŖŗŚśŜŝŠšŞşŤťŢţŦŧÚúÙùŬŭÛûǓǔŮůÜüǗǘǛǜǙǚǕǖŰűŨũŲųŪūỦủƯưỨứỪừỮữỬửỰựỤụẂẃẀẁŴŵẄẅÝýỲỳŶŷŸÿỸỹỶỷỴỵŹźŽžŻż';
		String resultString = apexTextUtility.removeDiacritics(testString);
		system.assertNotEquals(testString, resultString);
	}
	/**
	 * Tests <<apexTextUtility>>.formatDate
	 */
	public static testMethod void testFormatDate()
	{
		for(Integer i=1; i <= 12; i++)
		{
			Date d = Date.newInstance(Date.today().year(), i, 1);
			String result = apexTextUtility.formatDate(d);
			if(i == 12)
				System.assertEquals('December 1, ' + Date.today().year(), result);
		}
	}
}