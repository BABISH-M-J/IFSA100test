/**
 * ViewModel class for Advisor Portal, Application Item Details
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class advisorStudentsAppItemViewModel
{
	/**
	 * Application Item Id
	 */
	public String id {get;set;}
	/**
	 * Application Item Name
	 */
	public String name {get;set;}
	/**
	 * Application Item Record Type Developer Name
	 */
	public String recordType {get;set;}
	/**
	 * Application Item Directions
	 */
	public String directions {get;set;}
	/**
	 * Application Item Phase
	 */
	public String phase {get;set;}
	/**
	 * Application Item Status
	 */
	public String status {get;set;}
	/**
	 * Application Item Content
	 */
	public String content {get;set;}
	/**
	 * Application Item Text to Sign
	 */
	public String textToSign {get;set;}
	/**
	 * Application Item Content Link
	 */
	public String contentLink {get;set;}
	/**
	 * C&C Participation
	 */
	public String ccParticipation {get;set;}
	/**
	 * Arabic - CE Aural Comprehension
	 */
	public String ceAuralComprehension {get;set;}
	/**
	 * Arabic - CE Reading
	 */
	public String ceReading {get;set;}
	/**
	 * Arabic - CE Speaking
	 */
	public String ceSpeaking {get;set;}
	/**
	 * Arabic - CE Writing
	 */
	public String ceWriting {get;set;}
	/**
	 * Arabic - H Aural Comprehension
	 */
	public String hAuralComprehension {get;set;}
	/**
	 * Arabic - H Reading
	 */
	public String hReading {get;set;}
	/**
	 * Arabic - H Speaking
	 */
	public String hSpeaking {get;set;}
	/**
	 * Arabic - H Writing
	 */
	public String hWriting {get;set;}
	/**
	 * Arabic - MSA Aural Comprehension
	 */
	public String msaAuralComprehension {get;set;}
	/**
	 * Arabic - MSA Reading
	 */
	public String msaReading {get;set;}
	/**
	 * Arabic - MSA Speaking
	 */
	public String msaSpeaking {get;set;}
	/**
	 * Arabic - MSA Writing
	 */
	public String msaWriting {get;set;}
	/**
	 * Arabic - P Aural Comprehension
	 */
	public String pAuralComprehension {get;set;}
	/**
	 * Arabic - P Reading
	 */
	public String pReading {get;set;}
	/**
	 * Arabic - P Speaking
	 */
	public String pSpeaking {get;set;}
	/**
	 * Arabic - P Writing
	 */
	public String pWriting {get;set;}
	/** Regularly Speak */
	public String regularlySpeak {get;set;}
	/**
	 * Discipline
	 */
	public String discipline {get;set;}
	/**
	 * Disciplinary Action Explanation
	 */
	public String disciplinaryActionExplanation {get;set;}
	/**
	 * Good Standing
	 */
	public String goodStanding {get;set;}
	/**
	 * Good Standing Explanation
	 */
	public String goodStandingExplanation {get;set;}
	/**
	 * Academic Probation
	 */
	public String academicProbation {get;set;}
	/**
	 * Academic Probation Explanation
	 */
	public String academicProbationExplanation {get;set;}
	/**
	 * Approval To Study
	 */
	public String approvalToStudy {get;set;}
	/**
	 * Approval To Study Explanation
	 */
	public String approvalToStudyExplanation {get;set;}
	/**
	 * Pending Home Institution Final Approval
	 */
	public Boolean pendingHomeInstitutionFinalApproval {get; set;}
	/**
	 * Required Academic Conditions
	 */
	public Boolean requiredAcademicConditions {get; set;}
	/**
	 * Medical Psych Conditions Explanation
	 */
	public String medicalPsychConditionsExplanation {get;set;}
	/**
	 * Current Treatment Description
	 */
	public String currentTreatmentDescription {get;set;}
	/**
	 * Language
	 */
	public String language {get;set;}
	/**
	 * Learning Disability Description
	 */
	public String learningDisabilityDescription {get;set;}
	/**
	 * Ongoing Medical Attention Description
	 */
	public String ongoingMedicalAttentionDescription {get;set;}
	/**
	 * Physical Activity Restrictions Description
	 */
	public String physActivityRestrictionsDescription {get;set;}
	/**
	 * Housing Restrictions Description
	 */
	public String housingRestrictionsDescription {get;set;}
	/**
	 * Allergic To
	 */
	public String allergicTo {get;set;}
	/**
	 * Typical Reaction
	 */
	public String typicalReaction {get;set;}
	/**
	 * Emergency Treatment
	 */
	public String emergencyTreatment {get;set;}
	/**
	 * Food Allergy Arrangement Description
	 */
	public String foodAllergyArrangementDescription {get;set;}
	/**
	 * Medical Dietary Restriction Description
	 */
	public String medicalDietaryRestrictionDescription {get;set;}
	/**
	 * Medication Allergies Description
	 */
	public String medicationAllergiesDescription {get;set;}
	/**
	 * Other Medical DataDescription
	 */
	public String otherMedicalDataDescription {get;set;}
	/**
	 * Evaluator Email
	 */
	public String evaluatorEmail {get;set;}
	/**
	 * Evaluator Name
	 */
	public String evaluatorName {get;set;}
	/**
	 * Religious Accomodations
	 */
	public String religiousAccomodations {get;set;}
	/**
	 * Roommate Requests
	 */
	public String roommateRequests {get;set;}
	/**
	 * Dietary Restrictions
	 */
	public String dietaryRestrictions {get;set;}
	/**
	 * Housing Option
	 */
	public String housingOption {get;set;}
	/**
	 * Housing Options - All options the student is allowed to select for their program
	 */
	public List<String> housingOptions {get;set;}
	/**
	 * Commercial Teaching Rosetta Stone Etc
	 */
    public Boolean commercialTeachingRosettaStoneEtc {get;set;}
	/**
	 * Community Courses
	 */
	public Boolean communityCourses{get;set;}
	/**
	 * Heritage Speaker
	 */
	public Boolean heritageSpeaker {get;set;}
	/**
	 * High School Courses
	 */
	public Boolean highSchoolCourses {get;set;}
	/**
	 * University Courses
	 */
	public Boolean universityCourses{get;set;}
	/**
	 * Speaks Arabic
	 */
	public Boolean speaksArabic {get;set;}
	/**
	 * Speaks Colloquial Egyptian
	 */
	public Boolean speaksColloquialEgyptian {get;set;}
	/**
	 * Speaks Hebrew
	 */
	public Boolean speaksHebrew {get;set;}
	/**
	 * Speaks Palestinian
	 */
	public Boolean speaksPalestinian {get;set;}
	/**
	 * Medical Psych Conditions
	 */
	public Boolean medicalPsychConditions {get;set;}
	/**
	 * Medical Psych Conditions Treatment
	 */
	public Boolean medicalPsychConditionsTreatment {get;set;}
	/**
	 * Learning Disability
	 */
	public Boolean learningDisability {get;set;}
	/**
	 * Current Treatment
	 */
	public Boolean currentTreatment {get;set;}
	/**
	 * Ongoing Medical Attention
	 */
	public Boolean ongoingMedicalAttention {get;set;}
	/**
	 * Physical Activity Restrictions
	 */
	public Boolean physicalActivityRestrictions {get;set;}
	/**
	 * Housing Restrictions
	 */
	public Boolean housingRestrictions {get;set;}
	/**
	 * Food Allergies
	 */
	public Boolean foodAllergies {get;set;}
	/**
	 * EPI Pen
	 */
	public Boolean epiPen {get;set;}
	/**
	 * Food Allergy Special Arrangments
	 */
	public Boolean foodAllergySpecialArrangments {get;set;}
	/**
	 * Medical Dietary Restriction
	 */
	public Boolean medicalDietaryRestriction {get;set;}
	/**
	 * Medication Allergies
	 */
	public Boolean medicationAllergies {get;set;}
	/**
	 * Other Medical Data
	 */
	public Boolean otherMedicalData {get;set;}
	/**
	 * Display Non Smoking
	 */
	public Boolean displaynonsmoking {get;set;}
	/**
	 * Non Smoking
	 */
	public Boolean nonSmoking {get;set;}
	/**
	 * Display Smoking
	 */
	public Boolean displaysmoking {get;set;}
	/**
	 * Smoking
	 */
	public Boolean smoking {get;set;}
	/**
	 * Display Private Bathroom
	 */
	public Boolean displayprivatebathroom {get;set;}
	/**
	 * Private Bathroom
	 */
	public Boolean privateBathroom {get;set;}
	/**
	 * Display Single Room
	 */
	public Boolean displaysingleroom {get;set;}
	/**
	 * SingleRoom
	 */
	public Boolean singleRoom {get;set;}
	/**
	 * Display Single Gender
	 */
	public Boolean displaysinglegender {get;set;}
	/**
	 * Single Gender
	 */
	public Boolean singleGender {get;set;}
	/**
	 * Display Catered
	 */
	public Boolean displaycatered {get;set;}
	/**
	 * Catered
	 */
	public Boolean catered {get;set;}
	/**
	 * Display Off Campus
	 */
	public Boolean displayoffcampus {get;set;}
	/**
	 * Off Campus
	 */
	public Boolean offCampus {get;set;}
	/**
	 * Display On Campus
	 */
	public Boolean displayoncampus {get;set;}
	/**
	 * On Campus
	 */
	public Boolean onCampus {get;set;}
	/**
	 * Display Self Catered
	 */
	public Boolean displayselfcatered {get;set;}
	/**
	 * Self Catered
	 */
	public Boolean selfCatered {get;set;}
	/**
	 * Display Religious Accomodations
	 */
	public Boolean displayReligiousAccomodations {get;set;}
	/**
	 * Display Roommate Requests
	 */
	public Boolean displayroommaterequests {get;set;}
	/**
	 * Display Vegetarian
	 */
	public Boolean displayvegetarian {get;set;}
	/**
	 * Vegetarian
	 */
	public Boolean vegetarian {get;set;}
	/**
	 * Display Kosher
	 */
	public Boolean displaykosher {get;set;}
	/**
	 * Kosher
	 */
	public Boolean kosher {get;set;}
	/**
	 * Display Gluten Free
	 */
	public Boolean displayglutenfree {get;set;}
	/**
	 * Gluten Free
	 */
	public Boolean glutenFree {get;set;}
	/**
	 * Display Vegan
	 */
	public Boolean displayVegan {get;set;}
	/**
	 * Vegan
	 */
	public Boolean vegan {get;set;}
	/**
	 * Display Halal
	 */
	public Boolean displayHalal {get;set;}
	/**
	 * Halal
	 */
	public Boolean halal {get;set;}
	/**
	 * Display Other
	 */
	public Boolean displayother {get;set;}
	/**
	 * Other
	 */
	public Boolean other {get;set;}
	/**
	 * Display Lactose Intolerant
	 */
	public Boolean displaylactoseintolerant {get;set;}
	/**
	 * Lactose Intolerant
	 */
	public Boolean lactoseIntolerant {get;set;}
	/**
	 * Display Food Allergies
	 */
	public Boolean displayfoodallergies {get;set;}
	/**
	 * Display Dietary Restrictions
	 */
	public Boolean displaydietaryrestrictions {get;set;}
	/**
	 * Will Attend Religious Service
	 */
	public Boolean willAttendReligiousService {get;set;}
	/**
	 * Personal Interests
	 */
	public String personalInterests {get;set;}
	/**
	 * Music Preferences
	 */
	public String musicPreferences {get;set;}
	/**
	 * Children
	 */
	public Boolean children {get;set;}
	/**
	 * Display Signature
	 */
	public Boolean displaySignature {get;set;}
	/**
	 * Will Have Group Travel
	 */
	public String willHaveGroupTravel {get;set;}
	/**
	 * Travel Options
	 */
	public List<String> travelOptions {get;set;}
    //Learning Plan
	/**
	 * Academic Goals A
	 */
	public String academicGoalsA {get;set;}
	/**
	 * Academic Goals B
	 */
	public String academicGoalsB {get;set;}
	/**
	 * Academic Goals C
	 */
	public String academicGoalsC {get;set;}
	/**
	 * Personal Goals A
	 */
	public String personalGoalsA {get;set;}
	/**
	 * Personal Goals B
	 */
	public String personalGoalsB {get;set;}
	/**
	 * Personal Goals C
	 */
	public String personalGoalsC {get;set;}
	/**
	 * Professional Goals A
	 */
	public String professionalGoalsA {get;set;}
	/**
	 * Professional Goals B
	 */
	public String professionalGoalsB {get;set;}
	/**
	 * Professional Goals C
	 */
	public String professionalGoalsC {get;set;}
	/**
	 * Specific Actions 1
	 */
	public String specificActions1 {get;set;}
	/**
	 * Specific Actions 2
	 */
	public String specificActions2 {get;set;}
	/**
	 * Specific Actions 3
	 */
	public String specificActions3 {get;set;}
	/**
	 * Specific Actions 4
	 */
	public String specificActions4 {get;set;}
	/**
	 * Specific Actions 5
	 */
	public String specificActions5 {get;set;}
	/**
	 * Other Information
	 */
	public String otherInformation {get;set;}
	/**
	 * Learning Plan Disclosure
	 */
	public String learningPlanDisclosure {get;set;}
	/**
	 * Is Complete
	 */
	public Boolean isComplete {get;set;}
	/**
	 * Competency Options
	 */
	public List<String> competencyOptions {get;set;}
	/**
	 * Regularly Speak Options
	 */
	public List<String> regularlySpeakOptions {get;set;}
	/**
	 * C&C Participation Options
	 */
	public List<String> ccParticipationOptions {get;set;}
}