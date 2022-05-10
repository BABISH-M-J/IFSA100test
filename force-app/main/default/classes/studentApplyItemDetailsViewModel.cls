/**
* @description Viewmodel for Application_Item__c used with Application Item modal in student portal
* @author Cameron Ames
*/
public without sharing class studentApplyItemDetailsViewModel extends portalBaseViewModel
{
    public String id {get;set;}
    public String applicationId {get;set;}
    public String studentFirstName {get;set;}
    public String studentLastName {get;set;}
    public String studentName
    {
    	get
    	{
    		return studentFirstName + ' ' + studentLastName;
    	}
    }
	public String name {get;set;}
	public String recordType {get;set;}
	public String directions {get;set;}
    public String phase {get;set;}
    public String status {get;set;}
    public String content {get;set;}
	public String textToSign {get;set;}
	public String contentLink {get;set;}
	public String ccParticipation {get;set;}
    public String ceAuralComprehension {get;set;}
    public String ceReading {get;set;}
    public String ceSpeaking {get;set;}
    public String ceWriting {get;set;}
    public String hAuralComprehension {get;set;}
    public String hReading {get;set;}
    public String hSpeaking {get;set;}
    public String hWriting {get;set;}
    public String msaAuralComprehension {get;set;}
    public String msaReading {get;set;}
    public String msaSpeaking {get;set;}
    public String msaWriting {get;set;}
    public String pAuralComprehension {get;set;}
    public String pReading {get;set;}
    public String pSpeaking {get;set;}
    public String pWriting {get;set;}
    public String regularlySpeak {get;set;}
	public String discipline {get;set;}
	public String disciplinaryActionExplanation {get;set;}
	public String goodStanding {get;set;}
	public String goodStandingExplanation {get;set;}
	public String academicProbation {get;set;}
	public String academicProbationExplanation {get;set;}
	public String approvalToStudy {get;set;}
	public String approvalToStudyExplanation {get;set;}
	public Boolean pendingHomeInstitutionFinalApproval {get;set;}
	public Boolean requiredAcademicConditions {get;set;}
	public String medicalPsychConditionsExplanation {get;set;}
	public String currentTreatmentDescription {get;set;}
	public String language {get;set;}
	public String learningDisabilityDescription {get;set;}
	public String ongoingMedicalAttentionDescription {get;set;}
	public String physActivityRestrictionsDescription {get;set;}
	public String housingRestrictionsDescription {get;set;}
	public String allergicTo {get;set;}
	public String typicalReaction {get;set;}
	public String emergencyTreatment {get;set;}
	public String foodAllergyArrangementDescription {get;set;}
	public String fastFormsURL {get;set;}
	public String fastFormsTemplateID {get;set;}
	public String medicalDietaryRestrictionDescription {get;set;}
	public String medicationAllergiesDescription {get;set;}
	public String otherMedicalDataDescription {get;set;}
	public String evaluatorEmail {get;set;}
	public String evaluatorName {get;set;}
    public String religiousAccomodations {get;set;}
    public String roommateRequests {get;set;}
    public String dietaryRestrictions {get;set;}
	public String housingOption {get;set;}
	public String mailingStreet {get;set;}
	public String mailingCity {get;set;}
	public String mailingState {get;set;}
	public String mailingCountry {get;set;}
	public String mailingZip {get;set;}
	public String billingStreet {get;set;}
	public String billingCity {get;set;}
	public String billingState {get;set;}
	public String billingCountry {get;set;}
	public String billingZip {get;set;}
	public String otherStreet {get;set;}
	public String otherCity {get;set;}
	public String otherState {get;set;}
	public String otherCountry {get;set;}
	public String otherZip {get;set;}
	public String recommendationWaived {get;set;}
	public String evalWaived {get;set;}
	public String question1Override {get;set;}
	public String question2Override {get;set;}
	public String question3Override {get;set;}
	public String question4Override {get;set;}
	public String question5Override {get;set;}
	public String question6Override {get;set;}
	public String question7Override {get;set;}
	public String question8Override {get;set;}
	public String question9Override {get;set;}
	public String question10Override {get;set;}
	public String question11Override {get;set;}
	public String question12Override {get;set;}
	public String question13Override {get;set;}
	public String question14Override {get;set;}
	public String question15Override {get;set;}
	public String question16Override {get;set;}
	public String question17Override {get;set;}
	public String question18Override {get;set;}
	public String question19Override {get;set;}
	public String question20Override {get;set;}
	public String question21Override {get;set;}
	public String question22Override {get;set;}
	public String question23Override {get;set;}
	public String question24Override {get;set;}
	public String question25Override {get;set;}
	public String question26Override {get;set;}
	public String directoryOptOutStatus {get;set;}
	public List<Map<String, String>> housingOptions {get;set;}
	public Boolean isCustom {get;set;}
	public Boolean sameOtherAddress {get;set;}
	public Boolean sameBillingAddress {get;set;}
    public Boolean commercialTeachingRosettaStoneEtc {get;set;}
    public Boolean communityCourses{get;set;}
    public Boolean heritageSpeaker {get;set;}
    public Boolean highSchoolCourses {get;set;}
    public Boolean universityCourses{get;set;}
    public Boolean speaksArabic {get;set;}
    public Boolean speaksColloquialEgyptian {get;set;}
    public Boolean speaksHebrew {get;set;}
    public Boolean speaksPalestinian {get;set;}
	public Boolean medicalPsychConditions {get;set;}
	public Boolean medicalPsychConditionsTreatment {get;set;}
	public Boolean learningDisability {get;set;}
	public Boolean currentTreatment {get;set;}
	public Boolean ongoingMedicalAttention {get;set;}
	public Boolean physicalActivityRestrictions {get;set;}
	public Boolean housingRestrictions {get;set;}
	public Boolean foodAllergies {get;set;}
	public Boolean epiPen {get;set;}
	public Boolean foodAllergySpecialArrangments {get;set;}
	public Boolean medicalDietaryRestriction {get;set;}
	public Boolean medicationAllergies {get;set;}
	public Boolean otherMedicalData {get;set;}
    public Boolean displaynonsmoking {get;set;}
    public Boolean nonSmoking {get;set;}
    public Boolean displaysmoking {get;set;}
    public Boolean smoking {get;set;}
    public Boolean displayprivatebathroom {get;set;}
    public Boolean privateBathroom {get;set;}
    public Boolean displaysingleroom {get;set;}
    public Boolean singleRoom {get;set;}
    public Boolean displaysinglegender {get;set;}
    public Boolean singleGender {get;set;}
    public Boolean displaycatered {get;set;}
    public Boolean catered {get;set;}
    public Boolean displayoffcampus {get;set;}
    public Boolean offCampus {get;set;}
    public Boolean displayoncampus {get;set;}
    public Boolean onCampus {get;set;}
    public Boolean displayselfcatered {get;set;}
    public Boolean selfCatered {get;set;}
    public Boolean displayReligiousAccomodations {get;set;}
    public Boolean displayroommaterequests {get;set;}
    public Boolean displayvegetarian {get;set;}
    public Boolean vegetarian {get;set;}
    public Boolean displayneatnesslevel {get;set;}
    public String neatnesslevel {get;set;}
    public Boolean displaytypicalbedtime {get;set;}
    public String typicalbedtime {get;set;}    
    public Boolean displaykosher {get;set;}
    public Boolean kosher {get;set;}
    public Boolean displayglutenfree {get;set;}
    public Boolean glutenFree {get;set;}
    public Boolean displayVegan {get;set;}
    public Boolean vegan {get;set;}
    public Boolean displayHalal {get;set;}
    public Boolean halal {get;set;}
    public Boolean displayShabbat {get;set;}
    public Boolean shabbat {get;set;}
    public Boolean displayother {get;set;}
    public Boolean other {get;set;}
    public Boolean displaylactoseintolerant {get;set;}
    public Boolean lactoseIntolerant {get;set;}
    public Boolean displayfoodallergies {get;set;}
    public Boolean displaydietaryrestrictions {get;set;}
	public Boolean willAttendReligiousService {get;set;}
	public Boolean notCurrentlyEnrolled {get;set;}
	public String personalInterests {get;set;}
	public String musicPreferences {get;set;}
	public List<Integer> housingRankOptions {get;set;}
	public Boolean children {get;set;}
	public Boolean displaySignature {get;set;}

	public String willHaveGroupTravel {get;set;}
	public Date arrivalDate {get;set;}
	public String arrivalInstructions {get;set;}
	public String arrivalCity {get;set;}
	public List<Flight__c> flights {get;set;}
	public String arrivalPlanId {get;set;}
	public Date programEndDate {get;set;}
	
	public String advisorFirstName {get;set;}
	public String advisorLastName {get;set;}
	public String advisorEmail {get;set;}
	
	public List<String> travelOptions {get;set;}

	public Integer numberOfRecommendations {get;set;}
	public Boolean isComplete {get;set;}
	public Boolean isStarted {get;set;}
	public Boolean isTranscript {get;set;}

	public List<String> competencyOptions {get;set;}

	public List<String> regularlySpeakOptions {get;set;}

	public List<String> ccParticipationOptions {get;set;}

	public List<studentHomeSchoolCourseViewModel> courses {get;set;}
	
	public List<studentRecommendationItemViewModel> recommendations {get;set;}
	public List<string>attachments {get;set;}
	public List<Attachment> files {get;set;}
	public List<model_Essay_Question> essayQuestions {get;set;}
	
	public Date passportExpirationDate {get;set;}
	public String passportNumber {get;set;}
	public String passportCountry {get;set;}
	public Boolean passportDoNotHave {get;set;}
	public List<String> passportCountryOptions {get;set;}
	public Boolean passportDataSubmitted {get;set;}
	public Boolean passportInRenewal {get;set;}
	
	public model_contact emptyContact {get;set;}
	public List<model_contact> relatedContacts {get;set;}
	
	public Boolean doNotContact {get;set;}
	public Boolean doContact {get;set;}
	
	public String eContactFirstName {get;set;}
	public String eContactLastName {get;set;}
	public String eContactPhone {get;set;}
	public String eContactMobile {get;set;}
	public String eContactHomePhone {get;set;}
	public String eContactEmail {get;set;}
	public String eContactStreet {get;set;}
	public String eContactCity {get;set;}
	public String eContactState {get;set;}
	public String eContactZip {get;set;}
	public String eContactCountry {get;set;}
	public String eContactRelationship {get;set;}	
	public Id eContactId {get;set;}
	
	public String eContact2FirstName {get;set;}
	public String eContact2LastName {get;set;}
	public String eContact2Phone {get;set;}
	public String eContact2Mobile {get;set;}
	public String eContact2HomePhone {get;set;}
	public String eContact2Email {get;set;}
	public String eContact2Street {get;set;}
	public String eContact2City {get;set;}
	public String eContact2State {get;set;}
	public String eContact2Zip {get;set;}
	public String eContact2Country {get;set;}
	public String eContact2Relationship {get;set;}
	public Id eContact2Id {get;set;}
	
	public String parentGuardianFirstName {get;set;}
	public String parentGuardianLastName {get;set;}
	public String parentGuardianPhone {get;set;}
	public String parentGuardianMobile {get;set;}
	public String parentGuardianHomePhone {get;set;}
	public String parentGuardianEmail {get;set;}
	public String parentGuardianStreet {get;set;}
	public String parentGuardianCity {get;set;}
	public String parentGuardianState {get;set;}
	public String parentGuardianZip {get;set;}
	public String parentGuardianCountry {get;set;}
	public String parentGuardianRelationship {get;set;}
	public Id parentGuardianId {get;set;}

	public String parentGuardian2FirstName {get;set;}
	public String parentGuardian2LastName {get;set;}
	public String parentGuardian2Phone {get;set;}
	public String parentGuardian2Mobile {get;set;}
	public String parentGuardian2HomePhone {get;set;}
	public String parentGuardian2Email {get;set;}
	public String parentGuardian2Street {get;set;}
	public String parentGuardian2City {get;set;}
	public String parentGuardian2State {get;set;}
	public String parentGuardian2Zip {get;set;}
	public String parentGuardian2Country {get;set;}
	public String parentGuardian2Relationship {get;set;}
	public Id parentGuardian2Id {get;set;}
	
	public List<String> eContactRelationshipOptions {get;set;}
	public List<String> pContactRelationshipOptions {get;set;}
	
	//Scholarship	
	public Boolean FASFA {get; set;}
	public Double EFC {get; set;}
	public Double TuitionRemission {get; set;}
	public Double TuitionDiscount  {get; set;}
	public Double CollegeSavingsPlan {get; set;}
	public Double VABenefits {get; set;}
	public Double AmountStudentCanPay {get; set;}
	public Double AmountFamilyCanPay {get; set;}
	public Double HomeTuition {get; set;}
	public Double HomeStudyAbroadFees {get; set;}
	public Boolean IFSAGeneral {get; set;}
	public Boolean FirstGen {get; set;}
	public Boolean GAPScholarship {get; set;}
	public Boolean IFSAWorkStudy {get; set;}
	public String FinancialAidOfficersName {get; set;}
	public String FinancialAidOfficersPhone {get; set;}
	public String FinancialAidOfficersEmail {get; set;}
	public List<FinancialAidItemViewModel> aidList {get; set;}
	
	//Learning Plan
	public Boolean learningPlanUpdate {get;set;}
	public String academicGoalsA {get;set;}
	public String academicGoalsB {get;set;}
	public String academicGoalsC {get;set;}
	public String personalGoalsA {get;set;}
	public String personalGoalsB {get;set;}
	public String personalGoalsC {get;set;}
	public String professionalGoalsA {get;set;}
	public String professionalGoalsB {get;set;}
	public String professionalGoalsC {get;set;}
	public String specificActions1 {get;set;}
	public String specificActions2 {get;set;}
	public String specificActions3 {get;set;}
	public String specificActions4 {get;set;}
	public String specificActions5 {get;set;}
	public String otherInformation {get;set;}
	public String academicGoalsAOriginal {get;set;}
	public String academicGoalsBOriginal {get;set;}
	public String academicGoalsCOriginal {get;set;}
	public String personalGoalsAOriginal {get;set;}
	public String personalGoalsBOriginal {get;set;}
	public String personalGoalsCOriginal {get;set;}
	public String professionalGoalsAOriginal {get;set;}
	public String professionalGoalsBOriginal {get;set;}
	public String professionalGoalsCOriginal {get;set;}
	public String specificActions1Original {get;set;}
	public String specificActions2Original {get;set;}
	public String specificActions3Original {get;set;}
	public String specificActions4Original {get;set;}
	public String specificActions5Original {get;set;}
	public String otherInformationOriginal {get;set;}
	public String learningPlanDisclosure {get;set;}

	//FF Workaround field
	public Boolean hasAccountTradingCurrency {get;set;}
	// Dynamic Forms
	public dynamicFormViewModel form {get;set;}

	public Boolean hideStudyAbroadWording {get;set;}
	

	public studentApplyItemDetailsViewModel()
	{
		this.relatedContacts = new List<model_contact>();
		this.emptyContact = new model_contact();
		this.essayQuestions = new List<model_Essay_Question>();
	}

}