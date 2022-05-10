global class ScheduledCSPPurge implements Schedulable {
	global void execute(SchedulableContext sc) {
		contactSupportPersonnelService.purgeCSP();
	}
}