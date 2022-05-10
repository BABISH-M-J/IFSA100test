/*
* @description programOptionConverterUtility was the name of a class that was no longer used.
* @description It now holds methods for the Program Renaming Project.
* @author Tim Osborn - November 2019
*
* splitSummerProgram is Designed to work on the following programs:
* 'King\\\'s College London'
* 'London School of Economics and Political Science'
* 'National University of Ireland, Galway' 
* 'University of Stirling'
* 'University of Sussex'
* 'University of Westminster'; 
* 'University of the Arts, London'
*
* splitPrograms is designed to work on the following programs and options:
* 'University of Oxford', 'Hertford College'
* 'University of Oxford', 'Lady Margaret Hall'
* 'University of Oxford', 'Mansfield College'
* 'University of Oxford', 'Regent\'s Park College'
* 'University of Oxford', 'St. Anne\'s College'
* 'University of Oxford', 'St. Catherine\'s College'
* 'University of Oxford', 'St. Edmund Hall'
* 'University of Oxford', 'Worcester College'
*
* splitProgramsUAL is designed to work on the following programs and options:
* 'University of the Arts, London', 'Semester'
* 'University of the Arts, London', 'Studio Art'  
* 
* renameStudioArt is made to run after everything else.    
*/
public class programOptionConverterUtility {
    /*
    public class noneException extends Exception {}
    public class multipleException extends Exception {}
    Map<Program_Option__c, Program_Option__c> newPOs = new Map<Program_Option__c, Program_Option__c>();

    public static void splitSummerProgram(String programName) {
        BaseTriggerHandler.bypass('programTriggerHandler');
        BaseTriggerHandler.bypass('accountTriggerHandler');
        Program__c prog = new Program__c();
        String str = getCreatableFieldsSOQL('Program__c', 'Name = \'' + programName + '\'');
        List<Program__c> progs = Database.query(str);
        if (progs.size() < 1) {
            throw new noneException('No program by that name.');
        } else if(progs.size() > 1) {
            throw new multipleException('Multiple programs with that name.');
        } else {
            prog = progs[0];
        }
        System.debug('Program is:' + prog);
        Program__c summerProg = prog.clone(false,true,false,false);
        summerProg.Name = summerProg.Name + ' Summer';
        insert summerProg;
        updateBillingArrangements(prog, summerProg);
        updateCMPPrograms(prog, summerProg);
        updateProgramAuthorizations(prog, summerProg);
        updateProgramCourses(prog, summerProg);
        updateProgramInstitutions(prog, summerProg);
        updateProgramOptions(prog, summerProg);
        updateProgramTerms(prog, summerProg);
        updateResourceItems(prog, summerProg);
        updateRestrictedPrograms(prog, summerProg);
        updateSupportPersonnel(prog, summerProg);
        updateAttachments(prog.Id, summerProg.Id);
        updateNotes(prog, summerProg);
    }

    public static void fixPreMed() {
        BaseTriggerHandler.bypass('accountTriggerHandler');
        BaseTriggerHandler.bypass('programTermTriggerHandler');
        Program__c prog = new Program__c();
        Program__c PMprog = new Program__c();
        String str = 'SELECT Id, Name FROM Program__c WHERE Name = \'King\\\'s College London Premedical Program\' OR Name = \'King\\\'s College London\'';
        List<Program__c> progs = Database.query(str);
        if (progs.size() < 2) {
            throw new noneException('Pre-Med Programs not found.');
        } else if(progs.size() > 2) {
            throw new multipleException('Too many programs found.');
        } else {
            for (Program__c p : progs){
                if (p.Name == 'King\'s College London') {
                    prog = p;
                } else if (p.Name == 'King\'s College London Premedical Program') {
                    PMprog = p;
                } else {
                    throw new noneException('Correct programs not found.');
                }
            }
        }
        System.debug('Program is:' + prog);
        System.debug('PM Program is:' + PMprog);        
        String optName = 'Pre-Med Option: Health and Society';
        //updateBillingArrangementsNonSummer(prog, PMprog);
        updateCMPPrograms(prog, PMprog);
        updateProgramAuthorizationsNonSummer(prog, PMprog);
        //updateProgramCourses(prog, PMprog);
        updateProgramInstitutions(prog, PMprog);
        updateProgramOptionsNonSummer(prog, PMprog, optName);
        updateProgramTermsNonSummer(prog, PMprog, optName);
        updateResourceItems(prog, PMprog);
        updateRestrictedPrograms(prog, PMprog);
        updateSupportPersonnel(prog, PMprog);
        updateAttachments(prog.Id, PMprog.Id);
        updateNotes(prog, PMprog);
    }

    public static void SplitPrograms(String pName, String oName) {
        BaseTriggerHandler.bypass('programTriggerHandler');
        BaseTriggerHandler.bypass('accountTriggerHandler');
        BaseTriggerHandler.bypass('programTermTriggerHandler');
        BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');
		BaseTriggerHandler.bypass('programAuthorizationTriggerHandler');
        Program__c prog = new Program__c();
        Program__c newProg = new Program__c();
        String str = getCreatableFieldsSOQL('Program__c', 'Name = \'' + pName + '\'');
        List<Program__c> progs = Database.query(str);
        if (progs.size() < 1) {
            throw new noneException('No program by that name.');
        } else if(progs.size() > 1) {
            throw new multipleException('Multiple programs with that name.');
        } else {
            prog = progs[0];
        }
        System.debug('Program is:' + prog);
        String HIname = pName + ' _ ' + oName;
        String his = 'SELECT Id FROM Host_Institution__c WHERE Name LIKE \'' + String.escapeSingleQuotes(HIname) +'\' LIMIT 1';
        Host_Institution__c hi = Database.query(his);
        newProg = prog.clone(false,true,false,false);
        newProg.Name = newProg.Name + ' ' + oName;
        newProg.Host_Institution__c = hi.Id;
        insert newProg;
        updateBillingArrangementsNonSummer(prog, newprog);
        updateCMPPrograms(prog, newProg);
        updateProgramAuthorizationsNonSummer(prog, newProg);
        updateProgramCoursesNonSummer(prog, newProg, hi, oName);
        updateProgramInstitutions(prog, newProg);
        updateProgramOptionsNonSummer(prog, newProg, oName);
        updateProgramTermsNonSummer(prog, newProg, oName);
        updateResourceItems(prog, newProg);
        updateRestrictedPrograms(prog, newProg);
        updateSupportPersonnel(prog, newProg);
        updateAttachments(prog.Id, newProg.Id);
        updateNotes(prog, newProg); 
    }

    public static void SplitProgramsUAL(String pName, String oName) {
        BaseTriggerHandler.bypass('programTriggerHandler');
        BaseTriggerHandler.bypass('accountTriggerHandler');
        BaseTriggerHandler.bypass('programTermTriggerHandler');
        BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');
        BaseTriggerHandler.bypass('programAuthorizationTriggerHandler');
        Program__c prog = new Program__c();
        Program__c newProg = new Program__c();
        //String str = getCreatableFieldsSOQL('Program__c', 'Name = \'' + pName + '\'');
        String str = 'SELECT OwnerId,Name,CurrencyIsoCode,Academic_Affairs_Coordinator__c,Active__c,Category__c,Host_Institution__c,Language_Level__c,Language_of_Instruction__c,Primary_Location__Latitude__s,Primary_Location__Longitude__s,Time_Zone__c,Transcript_Needed__c,Type__c,Visa_Cost__c,Institution_Contact__c,Webpage_URL__c,Academics__c,Accompanying_Faculty__c,Advisor_Access_to_Portal__c,Any_Excursions_Requiring_Waiver__c,CISI_Plan__c,Enter_Flights__c,IFSA_Pays_Housing__c,IFSA_Pays_Tuition__c,Missing_Form_Follow_Up__c,Monitor_Flights__c,Program_Fee__c,Provide_email_to_CISI__c,Send_Advising_Emails__c,Send_Newsletter__c,Send_Parent_Packet__c,Student_Access_to_Portal__c,Student_Agreement__c,Transcript__c,Dim_1_Location__c,Dim_2_Host_School__c,Dim_3_Category__c,Country__c,Locality__c,Non_Refundable_Advance_Deposit__c,Abbreviated_Program_Name__c,C_C_Type__c,Create_IFSA_Butler_NET_Email__c,Custom_Program_Home_Instituiton_Account__c,Display_Account_Tab__c FROM Program__c WHERE Name = \'' + pName + '\'';
        List<Program__c> progs = Database.query(str);
        if (progs.size() < 1) {
            throw new noneException('No program by that name.');
        } else if(progs.size() > 1) {
            throw new multipleException('Multiple programs with that name.');
        } else {
            prog = progs[0];
        }
        System.debug('Program is:' + prog);
        newProg = prog.clone(false,true,false,false);
        newProg.Name = newProg.Name + ' ' + oName;
        insert newProg;
        updateBillingArrangementsNonSummer(prog, newprog);
        updateCMPPrograms(prog, newProg);
        updateProgramAuthorizationsNonSummer(prog, newProg);
        updateProgramCoursesUAL(prog, newProg);
        updateProgramInstitutions(prog, newProg);
        updateProgramOptionsUAL(prog, newProg, oName);
        updateProgramTermsUAL(prog, newProg, oName);
        updateResourceItems(prog, newProg);
        updateRestrictedPrograms(prog, newProg);
        updateSupportPersonnel(prog, newProg);
        updateAttachments(prog.Id, newProg.Id);
        updateNotes(prog, newProg);
    }
    

    public static void updateBillingArrangements(Program__c pro, Program__c sumPro) {
        List<Billing_Arrangement__c> updatedBAs = new List<Billing_Arrangement__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\' AND (Term__c INCLUDES (\'Summer\') OR Term__c = null)';
        String fldName = 'Billing_Arrangement__c';
        String str = getCreatableFieldsSOQL(fldName, qStr);
        List<Billing_Arrangement__c> BAs = Database.query(str);
        If (BAs.size() > 0) {
            for (Billing_Arrangement__c ba : BAs) {
                if (ba.Term__c == 'Summer'){
                    ba.Program__c = sumPro.Id;
                    updatedBAs.add(ba);
                } else {
                    Billing_Arrangement__c cpyBA = ba.clone(false,true,false,false);
                    cpyBA.Program__c = sumPro.Id;
                    updatedBAs.add(cpyBA);
                }
            }
        upsert updatedBAs;
        } 
    }

public static void updateBillingArrangementsNonSummer(Program__c pro, Program__c sumPro) {
        List<Billing_Arrangement__c> updatedBAs = new List<Billing_Arrangement__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\'';
        String fldName = 'Billing_Arrangement__c';
        String str = getCreatableFieldsSOQL(fldName, qStr);
        List<Billing_Arrangement__c> BAs = Database.query(str);
        If (BAs.size() > 0) {
            for (Billing_Arrangement__c ba : BAs) {
                Billing_Arrangement__c cpyBA = ba.clone(false,true,false,false);
                cpyBA.Program__c = sumPro.Id;
                IF (cpyBA.Term__c != null && cpyBA.Term__c.contains('Semester')) {
                        cpyBA.Term__c = cpyBA.Term__c.Replace('Semester 1', 'Spring');
                        cpyBA.Term__c = cpyBA.Term__c.Replace('Semester 2', 'Fall');
                    }  
                updatedBAs.add(cpyBA);                
            }
        upsert updatedBAs;
        } 
    }

    public static void updateCMPPrograms(Program__c pro, Program__c sumPro) {
        List< CMP_Program__c> updatedCMPPs = new List< CMP_Program__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\'';
        String str = getCreatableFieldsSOQL('CMP_Program__c', qStr);
        List< CMP_Program__c> CMPPs = Database.query(str);
        If (CMPPs.size() > 0) {
            for ( CMP_Program__c cmpp : CMPPs) {                
                CMP_Program__c cpyCMPP = cmpp.clone(false,true,false,false);
                cpyCMPP.Program__c = sumPro.Id;
                updatedCMPPs.add(cpyCMPP);
            }
        upsert updatedCMPPs;
        } 
    }

    public static void updateProgramAuthorizations(Program__c pro, Program__c sumPro) {
        List<Program_Authorization__c> updatedPAs = new List<Program_Authorization__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\' AND Term__c INCLUDES (\'Summer\')';
        //System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Program_Authorization__c', qStr, 'Account__r.Approves_All_Summer_Programs__c');
        //System.debug('str = ' + str);
        List<Program_Authorization__c> PAs = Database.query(str);
        //System.debug('PAs = ' + PAs);
        //System.debug('# of PAs = ' + PAs.size());
        If (PAs.size() > 0) {
            for (Program_Authorization__c pa : PAs) {
                //if (!pa.Account__r.Approves_All_Summer_Programs__c) {
                    if (pa.Term__c == 'Summer'){
                        pa.Program__c = sumPro.Id;
                        IF (pa.Term__c.contains('Semester')) {
                            pa.Term__c = pa.Term__c.Replace('Semester 1', 'Spring');
                            pa.Term__c = pa.Term__c.Replace('Semester 2', 'Fall');
                        }  
                        updatedPAs.add(pa);
                    } else {
                        Program_Authorization__c cpyPA = pa.clone(false,true,false,false);
                        cpyPA.Program__c = sumPro.Id;
                        IF (cpyPA.Term__c.contains('Semester')) {
                            cpyPA.Term__c = cpyPA.Term__c.Replace('Semester 1', 'Spring');
                            cpyPA.Term__c = cpyPA.Term__c.Replace('Semester 2', 'Fall');
                        }  
                        updatedPAs.add(cpyPA);
                    }
                //}                
            }
        upsert updatedPAs;
        } 
    }
    
    public static void updateProgramAuthorizationsNonSummer(Program__c pro, Program__c sumPro) {
        List<Program_Authorization__c> updatedPAs = new List<Program_Authorization__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\'';
        //System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Program_Authorization__c', qStr, 'Account__r.Approves_All_Calendar_Programs__c');
        //System.debug('str = ' + str);
        List<Program_Authorization__c> PAs = Database.query(str);
        //System.debug('PAs = ' + PAs);
        //System.debug('# of PAs = ' + PAs.size());
        If (PAs.size() > 0) {
            for (Program_Authorization__c pa : PAs) {
                //if (!pa.Account__r.Approves_All_Calendar_Programs__c) {
                    Program_Authorization__c cpyPA = pa.clone(false,true,false,false);
                    cpyPA.Program__c = sumPro.Id;
                    IF (cpyPA.Term__c.contains('Semester')) {
                        cpyPA.Term__c = cpyPA.Term__c.Replace('Semester 1', 'Spring');
                        cpyPA.Term__c = cpyPA.Term__c.Replace('Semester 2', 'Fall');
                    }  
                    updatedPAs.add(cpyPA);
                //}                
            }
        upsert updatedPAs;
        } 
    }
    
    public static void updateProgramCourses(Program__c pro, Program__c sumPro) {
        // Modify to only select courses in summer.
        List<Program_Course__c> updatedPCs = new List<Program_Course__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\' AND Course__r.US_Terms__c Includes (\'Summer\')';
        String str = getCreatableFieldsSOQL('Program_Course__c', qStr, 'Course__r.US_Terms__c');
        List<Program_Course__c> PCs = Database.query(str);
        If (PCs.size() > 0) { 
            for (Program_Course__c pc : PCs) {
                if (pc.Course__r.US_terms__c == 'Summer') {
                    pc.Program__c = sumPro.Id;
                    updatedPCs.add(pc);
                } else {
                    Program_Course__c cpyPC = pc.clone(false,true,false,false);
                    cpyPC.Program__c = sumPro.Id;
                    updatedPCs.add(cpyPC);  
                }                               
            }           
        upsert updatedPCs;
        } 
    }    

    public static void updateProgramCoursesNonSummer(Program__c pro, Program__c newPro, Host_Institution__c Host, String OpName) {
        //Modify to select course by program option (college)
        List<Program_Course__c> updatedPCs = new List<Program_Course__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\' AND (Course__r.Host_Institution__c = \'' + Host.Id + '\' OR Program_Option__r.Name LIKE \'' + String.escapeSingleQuotes(OpName) + '%\')';
        String str = getCreatableFieldsSOQL('Program_Course__c', qStr);
        List<Program_Course__c> PCs = Database.query(str);
        If (PCs.size() > 0) { 
            for (Program_Course__c pc : PCs) {
                Program_Course__c cpyPC = pc.clone(false,true,false,false);
                cpyPC.Program__c = newPro.Id;
                updatedPCs.add(cpyPC);                               
            }           
        upsert updatedPCs;
        } 
    }    
    
    public static void updateProgramCoursesUAL(Program__c pro, Program__c sumPro) {
        //Modify to exclude summer only courses
        List<Program_Course__c> updatedPCs = new List<Program_Course__c>();
        String qStr;
        if (sumPro.Name.contains('Studio Art')) {
            // qStr = 'Program__c = \'' + pro.Id + '\' AND (Course__r.Name LIKE \'Unit %\' OR Course__r.Name LIKE \'European Art History%\' OR Course__r.Name = \'Creative Industries London\' )';
            qStr = 'Program__c = \'' + pro.Id + '\' AND (Course__r.Name LIKE \'Unit %\' OR Course__r.Name LIKE \'European Art History%\' )';
        } else  if (sumPro.Name.contains('Semester')) {
            qStr = 'Program__c = \'' + pro.Id + '\' AND Course__r.US_Terms__c != \'Summer\' AND (NOT Course__r.Name LIKE \'Unit %\') AND (NOT Course__r.Name LIKE \'European Art History%\') ';
        } else {
            qStr = null;
        }
        String str = getCreatableFieldsSOQL('Program_Course__c', qStr);
        if (str == null) {
            return;
        }
        List<Program_Course__c> PCs = Database.query(str);
        If (PCs.size() > 0) { 
            for (Program_Course__c pc : PCs) {
                Program_Course__c cpyPC = pc.clone(false,true,false,false);
                cpyPC.Program__c = sumPro.Id;
                updatedPCs.add(cpyPC);                               
            }           
        //upsert updatedPCs;
        sObjectBatchUpdater.batchUpdate(updatedPCs, 200, sObjectBatchUpdater.dmlTypes.dmlUpsert);
        } 
    }    

    public static void updateProgramInstitutions(Program__c pro, Program__c sumPro) {
        List<Program_Institution__c> updatedPIs = new List<Program_Institution__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\'';
        String str = getCreatableFieldsSOQL('Program_Institution__c', qStr, 'Program__r.Name, Host_Institution__r.Name');
        List<Program_Institution__c> PIs = Database.query(str);
        If (PIs.size() > 0) { 
            for (Program_Institution__c pi : PIs) {
                //if (pi.Program__r.Name != pi.Host_Institution__r.Name) {
                    Program_Institution__c cpyPI = pi.clone(false,true,false,false);
                    cpyPI.Program__c = sumPro.Id;
                    updatedPIs.add(cpyPI); 
                //}                              
            }
        upsert updatedPIs;
        } 
    }

    public static void updateProgramOptions(Program__c pro, Program__c sumPro) {
        List<Program_Option__c> updatedPOs = new List<Program_Option__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\' AND Id IN (SELECT Program_Option__c FROM Program_Term__c WHERE Term__r.Section__c = \'Summer\')';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Program_Option__c', qStr);
        List<Program_Option__c> POs = Database.query(str);
        If (POs.size() > 0) {
            for (Program_Option__c po : POs) {                
                po.Program__c = sumPro.Id;
                updatedPOs.add(po);                                
            }
        upsert updatedPOs;
        } 
    }
    
    public static void updateProgramOptionsNonSummer(Program__c pro, Program__c sumPro, String oName) {
        List<Program_Option__c> updatedPOs = new List<Program_Option__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\' AND Name LIKE \'' + String.escapeSingleQuotes(oName) + '%\'';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Program_Option__c', qStr);
        List<Program_Option__c> POs = Database.query(str);
        If (POs.size() > 0) {
            for (Program_Option__c po : POs) {                
                po.Program__c = sumPro.Id;
                updatedPOs.add(po);                                
            }
        upsert updatedPOs;
        } 
    }

    public static void updateProgramOptionsUAL(Program__c pro, Program__c sumPro, String oName) {
        List<Program_Option__c> updatedPOs = new List<Program_Option__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\' AND Name LIKE \'% ' + oName + '\'';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Program_Option__c', qStr);
        List<Program_Option__c> POs = Database.query(str);
        If (POs.size() > 0) {
            for (Program_Option__c po : POs) {                
                po.Program__c = sumPro.Id;
                updatedPOs.add(po);                                
            }
        upsert updatedPOs;
        } 
    }

    public static void updateProgramTerms(Program__c pro, Program__c sumPro) {
        List<Program_Term__c> updatedPTs = new List<Program_Term__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\' AND Term__r.Section__c = \'Summer\'';
        String str = getCreatableFieldsSOQL('Program_Term__c', qStr);
        List<Program_Term__c> PTs = Database.query(str);
        If (PTs.size() > 0) {
            for (Program_Term__c pt : PTs) {
                pt.Program__c = sumPro.Id;
                updatedPTs.add(pt);   
            }
        update updatedPTs;
        } 
    }
      
    public static void updateProgramTermsNonSummer(Program__c pro, Program__c sumPro, String oName) {
        RecordType SPTrt = [SELECT Id FROM RecordType WHERE Name = 'Standard Program Term'][0];
        //System.debug('Standard Program Term = ' + SPTrt);
        List<Program_Term__c> updatedPTs = new List<Program_Term__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\' AND (Program_Option__r.Name LIKE \'' + String.escapeSingleQuotes(oName) + '%\' OR Is_Parent_Program_Term__c = true)';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Program_Term__c', qStr, 'is_Parent_Program_Term__c');
        List<Program_Term__c> PTs = Database.query(str);
        If (PTs.size() > 0) {
            Map<Program_Term__c, List<Program_Term__c>> ParProgTerms = new Map <Program_Term__c, List<Program_Term__c>>();
            for (Program_Term__c pt : PTs) {
                if (pt.is_Parent_Program_Term__c == true) {
                    List<Program_Term__c> l = new List<Program_Term__c>();
                    for (Program_Term__c cpt : PTs) {
                        if (cpt.Parent_Program_Term__c == pt.Id) {
                            l.add(cpt);
                        }
                    ParProgTerms.put(pt,l);
                    }
                }
            }
            for (Program_Term__c pt : ParProgTerms.keySet()) {
                if (ParProgTerms.get(pt).size() == 1) {
                    Program_Term__c programTerm = ParProgTerms.get(pt)[0];
                    programTerm.RecordTypeId = SPTrt.Id;
                    programTerm.Program__c = sumPro.Id;
                    programTerm.Parent_Program_Term__c = null;
                    update programTerm;
                    copyApplicationRequirements(pt, programTerm);
                    updateAttachments(pt.Id, programTerm.Id);
                    copyProgramFees(pt, programTerm);
                    copyProgramTermHousingOptions(pt, programTerm);
                } else if (ParProgTerms.get(pt).size() > 1) {
                    Program_Term__c newPT = pt.clone(false,true,false,false);
                    newPT.Name = 'Oxford ' + oName + pt.Name.substringAfter('d');
                    newPT.Program__c = sumPro.Id;
                    insert newPT;
                    for (Program_Term__c cpt : ParProgTerms.get(pt)) {
                        cpt.Program__c = sumPro.Id;
                        cpt.Parent_Program_Term__c = newPT.Id;
                        updatedPTs.add(cpt);
                    }
                    update updatedPTs;
                    copyApplicationRequirements(pt, newPT);
                    updateAttachments(pt.Id, newPT.Id);
                    copyProgramFees(pt, newPT);
                    copyProgramTermHousingOptions(pt, newPT);
                }
            }
        } 
    }
      
    public static void updateProgramTermsUAL(Program__c pro, Program__c sumPro, String oName) {
        RecordType SPTrt = [SELECT Id FROM RecordType WHERE Name = 'Standard Program Term'][0];
        //System.debug('Standard Program Term = ' + SPTrt);
        List<Program_Term__c> updatedPTs = new List<Program_Term__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\' AND (Program_Option__r.Name LIKE \'% ' + oName + '\' OR Is_Parent_Program_Term__c = true)';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Program_Term__c', qStr, 'is_Parent_Program_Term__c');
        List<Program_Term__c> PTs = Database.query(str);
        If (PTs.size() > 0) {
            Map<Program_Term__c, List<Program_Term__c>> ParProgTerms = new Map <Program_Term__c, List<Program_Term__c>>();
            for (Program_Term__c pt : PTs) {
                if (pt.is_Parent_Program_Term__c == true) {
                    List<Program_Term__c> l = new List<Program_Term__c>();
                    for (Program_Term__c cpt : PTs) {
                        if (cpt.Parent_Program_Term__c == pt.Id) {
                            l.add(cpt);
                        }
                    ParProgTerms.put(pt,l);
                    }
                }
            }
            for (Program_Term__c pt : ParProgTerms.keySet()) {
                if (ParProgTerms.get(pt).size() == 1) {
                    Program_Term__c programTerm = ParProgTerms.get(pt)[0];
                    programTerm.RecordTypeId = SPTrt.Id;
                    programTerm.Program__c = sumPro.Id;
                    programTerm.Parent_Program_Term__c = null;
                    update programTerm;
                    copyApplicationRequirements(pt, programTerm);
                    updateAttachments(pt.Id, programTerm.Id);
                    copyProgramFees(pt, programTerm);
                    copyProgramTermHousingOptions(pt, programTerm);
                } else if (ParProgTerms.get(pt).size() > 1) {
                    Program_Term__c newPT = pt.clone(false,true,false,false);
                    newPT.Name = 'the Arts, London ' + oName + pt.Name.substringAfter('don');
                    newPT.Program__c = sumPro.Id;
                    insert newPT;
                    for (Program_Term__c cpt : ParProgTerms.get(pt)) {
                        cpt.Program__c = sumPro.Id;
                        cpt.Parent_Program_Term__c = newPT.Id;
                        updatedPTs.add(cpt);
                    }
                    update updatedPTs;
                    copyApplicationRequirements(pt, newPT);
                    updateAttachments(pt.Id, newPT.Id);
                    copyProgramFees(pt, newPT);
                    copyProgramTermHousingOptions(pt, newPT);
                }
            }
        } 
    }
        

    public static void updateResourceItems(Program__c pro, Program__c sumPro) {
        List<Resource_Item__c> updatedRIs = new List<Resource_Item__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\'';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Resource_Item__c', qStr);
        List<Resource_Item__c> RIs = Database.query(str);
        If (RIs.size() > 0) {
            for (Resource_Item__c ri : RIs) {
                Resource_Item__c cpyRI = ri.clone(false,true,false,false);
                cpyRI.Program__c = sumPro.Id;
                updatedRIs.add(cpyRI);               
            }
        upsert updatedRIs;
        } 
    }


    public static void updateRestrictedPrograms(Program__c pro, Program__c sumPro) {
        List< Restricted_Program__c> updatedRPs = new List< Restricted_Program__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\'';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Restricted_Program__c', qStr);
        List< Restricted_Program__c> RPs = Database.query(str);
        If (RPs.size() > 0) {
            for ( Restricted_Program__c rp : RPs) {
                 Restricted_Program__c cpyRP = rp.clone(false,true,false,false);
                cpyRP.Program__c = sumPro.Id;
                updatedRPs.add(cpyRP);               
            }
        upsert updatedRPs;
        } 
    }

    public static void updateSupportPersonnel(Program__c pro, Program__c sumPro) {
        List<Support_Personnel__c> updatedSPs = new List<Support_Personnel__c>();
        String qStr = 'Program__c = \'' + pro.Id + '\'';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Support_Personnel__c', qStr);
        List<Support_Personnel__c> SPs = Database.query(str);
        If (SPs.size() > 0) {
            for (Support_Personnel__c sp : SPs) {
                Support_Personnel__c cpySP = sp.clone(false,true,false,false);
                cpySP.Program__c = sumPro.Id;
                updatedSPs.add(cpySP);               
            }
        upsert updatedSPs;
        } 
    }

    public static void updateAttachments(Id pro, Id sumPro) {
        List<Attachment> updatedAtts = new List<Attachment>();
        /-*String qStr = 'ParentId = \'' + pro + '\'';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Attachment', qStr);
        List<Attachment> Atts = Database.query(str);
        If (Atts.size() > 0) {
            for (Attachment att : Atts) {
                Attachment cpyAtt = att.clone(false,true,false,false);
                cpyAtt.ParentId = sumPro;
                updatedAtts.add(cpyAtt);               
            }
        upsert updatedAtts;
        } *-/
        System.debug('before loop: ' + Limits.getHeapSize() +'/' + Limits.getLimitHeapSize());
        for (Attachment att : [SELECT ParentId, Name, IsPrivate, ContentType, Body, OwnerId, Description 
                                FROM Attachment WHERE ParentId = :pro] ) {
            //System.debug('before clone: ' + Limits.getHeapSize() +'/' + Limits.getLimitHeapSize());
            //Attachment cpyAtt = att.clone(false,true,false,false);
            //System.debug('after clone: ' + Limits.getHeapSize() +'/' + Limits.getLimitHeapSize());
            //cpyAtt.ParentId = sumPro;
            //updatedAtts.add(cpyAtt);
            att.Id = null;
            att.ParentId = sumPro;
            updatedAtts.add(att);
            sObjectBatchUpdater.batchUpdate(updatedAtts, 1, sObjectBatchUpdater.dmlTypes.dmlInsert);
            updatedAtts.clear();
        }        
    }

public static void updateNotes(Program__c pro, Program__c sumPro) {
        List<Note> updatedNotes = new List<Note>();
        String qStr = 'ParentId = \'' + pro.Id + '\'';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Note', qStr);
        List<Note> Notes = Database.query(str);
        If (Notes.size() > 0) {
            for (Note nte : Notes) {
                Note cpyNote = nte.clone(false,true,false,false);
                cpyNote.ParentId = sumPro.Id;
                updatedNotes.add(cpyNote);               
            }
        upsert updatedNotes;
        } 
    }
    
public static void copyApplicationRequirements(Program_Term__c pt, Program_Term__c newPT) {
        //BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');
        List<String> triggers = new List<String>{'ApplicationRequirementTriggerHandler'};
        List<sObject> newARs = new List<SObject>();
        String qStr = 'Program_Term__c = \'' + pt.Id + '\'';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Application_Requirement__c', qStr);
        List<Application_Requirement__c > ARs = Database.query(str);
        If (ARs.size() > 0) {
            for (Application_Requirement__c  ar : ARs) {
                Application_Requirement__c  newAR = ar.clone(false,true,false,false);
                newAR.Program_Term__c = newPT.Id;
                newARs.add(newAR);               
            }

        sObjectQueueableUpdater insertARs = new sObjectQueueableUpdater(newARs, sObjectQueueableUpdater.dmlOperation.isInsert, triggers);
        ID jobID = System.enqueueJob(insertARs);
        System.debug('Job Id: ' + jobID);
        //sObjectBatchUpdater.batchUpdate(newARs, 200, sObjectBatchUpdater.dmlTypes.dmlInsert);
        //insert newARs;
        } 
    }

    public static void copyMissedApplicationRequirements(String pptName) {
        List<Program_Term__c> progterms = [SELECT Id, Name, Term__c FROM Program_Term__c WHERE Name LIKE :pptName + '%' AND Parent_Program_Term__c = null];
        List<Application_Requirement__c> AppReqs = [SELECT Id, Program_Term__c FROM Application_Requirement__c WHERE Program_Term__c IN :progterms];
        Map<Program_Term__c, Integer> apMap = new  Map<Program_Term__c, Integer>();
        for (Program_Term__c progTerm : progterms) {
            Integer x = 0;
            for (Application_Requirement__c ar : AppReqs){
                if (ar.Program_Term__c == progTerm.Id) {x ++;}
            }
        apMap.put(progTerm, x);
        }
        for (Program_Term__c p : apMap.keySet()) {
            if (p.Name == pptName) {
                for (Program_Term__c prTerm : apMap.keySet()) {
                    if (prTerm.Name != pptName && apMap.get(prTerm) < apMap.get(p) && prTerm.Term__c == p.Term__C) {
                        copyApplicationRequirements(p, prTerm);
                    }
                }
            }
        }
         
    }

public static void copyProgramFees(Program_Term__c pt, Program_Term__c newPT) {
        List<Program_Fee__c > newPFs = new List<Program_Fee__c >();
        String qStr = 'Program_Term__c = \'' + pt.Id + '\'';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Program_Fee__c', qStr);
        List<Program_Fee__c > PFs = Database.query(str);
        If (PFs.size() > 0) {
            for (Program_Fee__c  pf : PFs) {
                Program_Fee__c  newPF = pf.clone(false,true,false,false);
                newPF.Program_Term__c = newPT.Id;
                newPFs.add(newPF);               
            }
        sObjectBatchUpdater.batchUpdate(newPFs, 200, sObjectBatchUpdater.dmlTypes.dmlInsert);
        //insert newPFs;
        } 
    }
                    
public static void copyProgramTermHousingOptions(Program_Term__c pt, Program_Term__c newPT) {
        List<Program_Term_Housing_Option__c > newHOs = new List<Program_Term_Housing_Option__c >();
        String qStr = 'Program_Term__c = \'' + pt.Id + '\'';
        System.debug('qStr = ' + qStr);
        String str = getCreatableFieldsSOQL('Program_Term_Housing_Option__c', qStr);
        //List<Program_Term_Housing_Option__c > HOs = Database.query(str);
        //If (HOs.size() > 0) {
            for (Program_Term_Housing_Option__c  ho : Database.query(str)) {
                Program_Term_Housing_Option__c  newHO = ho.clone(false,true,false,false);
                newHO.Program_Term__c = newPT.Id;
                newHOs.add(newHO);               
            }
            sObjectBatchUpdater.batchUpdate(newHOs, 200, sObjectBatchUpdater.dmlTypes.dmlInsert);
        //insert newHOs;
        //
    }

    //overloading of method
    public static String getCreatableFieldsSOQL(String objectName, String whereClause) {   
        String x = null;     
        return programOptionConverterUtility.getCreatableFieldsSOQL(objectName, whereClause, x);
    }
    
    // getCreatableFieldsSOQL borrowed from http://sfdc.arrowpointe.com/2011/03/28/cloning-records-in-apex/
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause, String adds){        
        String selects = '';         
        if (whereClause == null || whereClause == ''){ return null; }         
        // Get a map of field name and field token
        if (objectName == null | objectName == '') {
            System.debug('objectName is null or empty');
        }
        System.debug('objectName = ' + objectName); 
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        System.debug('fMap = ' + fMap);
        list<string> selectFields = new list<string>();         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
            Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
            if (fd.isCreateable()){ // field is creatable
                selectFields.add(fd.getName());
                }
            }
        }         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (adds != null && adds != '') {
                selects += adds + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}             
        }         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;         
    }
    
    public static void renameStudioArt() {
        BaseTriggerHandler.bypass('programOptionTriggerHandler');
        BaseTriggerHandler.bypass('programTermTriggerHandler');
        BaseTriggerHandler.bypass('programTriggerHandler');
        BaseTriggerHandler.bypass('applicationTriggerHandler');
        String StA = 'Studio Art';
        String Inte = 'Integrated';
        Program__c sa = [SELECT Id, Name FROM Program__c WHERE Name = 'University of the Arts, London Studio Art' LIMIT 1];
        sa.Name = sa.Name.replace(StA, Inte);
        update sa;
        List<Program_Option__c> saPOs = [SELECT Id, Name FROM Program_Option__c WHERE Program__c = :sa.Id ]; 
        for (Program_Option__c saPO : saPOs) {
            saPO.Name = saPO.Name.replace(StA, Inte);
        }
        update saPOs;
        List<Program_Term__c> saPTs = [SELECT Id, Name, Program__r.Name, Program_Option_Name__c FROM Program_Term__c WHERE Program__c = :sa.Id AND (Term__r.Section__c = 'Fall' OR Term__r.Section__c = 'Academic Year') AND Term__r.Year__c > 2019]; 
        for (Program_Term__c saPT : saPTs) {
            saPT.Name = saPT.Name.replace(StA, Inte);
            if (saPT.Program_Option_Name__c != null) {
                saPT.Program_Option_Name__c = saPT.Program_Option_Name__c.replace(StA, Inte);
            }            
        }
        update saPTs;
        List<Application__c> saApps = [SELECT Id, Name FROM Application__c WHERE Program_Term__c IN :saPTs]; 
        for (Application__c saApp : saApps) {
            saApp.Name = saApp.Name.replace(StA, Inte);           
        }
        update saApps;
    }
    */
}