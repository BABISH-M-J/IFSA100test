var courseRegApp = angular.module('courseRegApp', ['ui.bootstrap']);    
    	courseRegApp.filter('ampersand', function(){
		    return function(input){
		        return input ? input.replace(/&amp;/g, '&') : '';
		    }
		});
		courseRegApp.filter('apostraphe', function(){
			return function(input){
				return input ? input.replace(/&#39;/g, "'") : '';
			}
		})
		courseRegApp.filter('sumOfValue', function () {
    		return function (data, key) {        
        		if (angular.isUndefined(data) || angular.isUndefined(key))
        	    	return 0;        
		        var sum = 0;        
		        for (let index = 0; index < data.length; index++) {
					const value = data[index];
	            	sum = sum + parseFloat(value[key]);
		        }
		        return sum.toFixed(2);
    		}
    	});
		courseRegApp.filter('sumOfValueNotDropped', function () {
    		return function (data, key) {        
        		if (angular.isUndefined(data) || angular.isUndefined(key))
        	    	return 0;        
				var sum = 0;
				for (let index = 0; index < data.length; index++) {
					const value = data[index];
					if(!value.isDropped){
						if(!value[key]){
							value[key] = 0;
						}
						sum = sum + parseFloat(value[key]);
					}
				}
		        return sum.toFixed(2);
    		}
    	});
    
    	courseRegApp.controller('courseRegController', function($scope, viewModel, $filter, ampersandFilter, apostrapheFilter, $timeout)
		{
			$scope.viewModel = viewModel.getViewModel();
			$scope.editMode = false;
			if($scope.viewModel.pageActionType == 'Grade_Report')
			{
				$scope.actionType = 'entered';
			}
			else if($scope.viewModel.pageActionType == 'Review_Grades')
			{
				$scope.actionType = 'reviewd';
			}

			angular.forEach($scope.viewModel.hostInstViewModels, function(host, key){
				angular.forEach(host.applicationCourses, function(app, key){
					app.fallCourses = [];
					app.springCourses = [];
					app.summerCourses = [];
					angular.forEach(app.courseRegistrations, function(course, key){
						if(course.courseTerm == 'Fall')
						{
							app.fallCourses.push(course);
						}
						else if(course.courseTerm == 'Spring')
						{
							app.springCourses.push(course);
						}
						else if(course.courseTerm == 'Summer')
						{
							app.summerCourses.push(course);
						}
						getQualityPoints(course, app);
					});
				});
			});

			clearEditedLine = function(){
				$scope.editedLine = {
					Id: "",
					Name: "",
					Course_Code__c: "",
					Department_Code__c: "",
					Instructor_Full_Name__c: "",
					Instructor_First_Name__c: "",
					Instructor_Last_Name__c: "",
					Host_Credits__c: "",
					US_Semester_Credit_Hours__c: "",
					Course_Term__c: ''
				};
			}
			clearAddNewCourse = function(app){
				app.addedCourse = {
					Id: null,
					Name: null,
					courseId: null,
					searchedHostInstitution: null,
					searchedHostInstitutionId: null,
					courseCode: null,
					departmentCode: null,
					instructorFirstName: null,
					instructorLastName: null,
					credits: null,
					usCredits: null,
					courseTerm: null
				};			
			}

			$scope.edit = function(course) {
				course.edit = true; 
				$scope.viewModel.editMode = true;
				$scope.editedLine.Id = course.courseId;
				$scope.editedLine.Name = course.courseTitle;
				$scope.editedLine.courseCode = course.courseCode;
				$scope.editedLine.departmentCode = course.departmentCode;
				$scope.editedLine.instructorFirstName = course.instructorFirstName;
				$scope.editedLine.instructorLastName = course.instructorLastName;
				$scope.editedLine.credits = course.credits;
				$scope.editedLine.usCredits = course.usCredits;
				$scope.editedLine.courseGrade = course.courseGrade;
				$scope.editedLine.courseTerm = course.courseTerm;
			}

			$scope.addCourse = function(app) {
				app.addCourse = true;
				clearAddNewCourse(app);
			}

			$scope.saveAddedCourse = function(course, createCourse, app){
				course.courseName = course.Name;
				course.courseTitle = course.courseName;
                course.applicationId = app.application.Id;
                course.hostInstitutionName = course.searchedHostInstitution;
                course.isDropped = course.isDropped ? true: false;
                if($scope.viewModel.pageActionType == 'Grade_Report')
                	course.isApproved = true;
				if(!createCourse)
				{
					courseRegistrationController.createCourse(					
					angular.toJson(course),
					createCourse,
					function(result, event){
						if(result){							
							course.courseId = result.courseId;
							app.courseRegistrations.push(course);
							$scope.$apply();
							alert("The course '" + course.courseName + "' has been saved");							
						}
						else{
							alert("The course '" + course.courseName + " has not been saved");
						}
					});
				}
				else
				{
					courseRegistrationController.createCourse(					
					angular.toJson(course),
					createCourse,
					function(result, event){
						if(result){							
							course.courseId = result.courseId;
							app.courseRegistrations.push(course);
							$scope.$apply();
                            //alert("The course '" + course.courseName + "' has been saved");
						}
						else{
							alert("The course '" + course.courseName + " has not been saved");
						}
					});

				}		
				app.addCourse = false
				$scope.viewModel.editMode = false;
				clearAddNewCourse();
			}

			$scope.save = function(course, createCourse, app){				
				course.Id = $scope.editedLine.Id;
				course.courseTitle = $scope.editedLine.Name;
				course.courseCode = $scope.editedLine.courseCode;
				course.courseId = $scope.editedLine.Id;
				course.departmentCode = $scope.editedLine.departmentCode;				
				course.instructorFirstName = $scope.editedLine.instructorFirstName;
				course.instructorLastName = $scope.editedLine.instructorLastName;
				course.instructorName = course.instructorFirstName + " " + course.instructorLastName;
				course.credits = $scope.editedLine.credits;
				course.usCredits = $scope.editedLine.usCredits;
				if($scope.editedLine.courseGrade != course.courseGrade)
				{
					course.gradeChanged = true;
				}
                course.courseGrade = $scope.editedLine.courseGrade;                
                course.courseTerm = $scope.editedLine.courseTerm;
				
				courseRegistrationController.createCourse(					
				angular.toJson(course),
				createCourse,
				function(result, event){
					if(result){							
						course.courseId = result.courseId;
						//set course status
						if(course.courseStatus == 'Approval Pending')
							course.courseStatus = 'Approved';
						else if(course.courseStatus == 'Approved')
							course.courseStatus = 'Grade Entered';
						else if((course.courseStatus == 'Grade Entered' || course.courseStatus == 'Grade Verified') && course.gradeChanged)
						{
							course.courseStatus = 'Grade Corrected';
							course.gradeChanged = false;
						}
						else if(course.courseStatus == 'Grade Submitted')
							course.courseStatus = 'Grade Revised';
						getQualityPoints(course, app);
						$scope.$apply();
						if(!createCourse)
							alert("The course '" + course.courseTitle + "' has been saved");
					}
					else{
						alert("The course '" + course.courseTitle + " has not been saved");
					}
				});
			
				course.edit = false; 
				$scope.viewModel.editMode = false;
				clearEditedLine();
			}
			function getQualityPoints(course, app){
				var weight;
				switch(course.courseGrade)
				{
					case 'A':
						weight = 4;
						break;
					case 'A-':
						weight = 3.67;
						break;
					case 'B+':
						weight = 3.33;
						break;
					case 'B':
						weight = 3;
						break;
					case 'B-':
						weight = 2.67;
						break;
					case 'C+':
						weight = 2.33;
						break;
					case 'C':
						weight = 2;
						break;
					case 'C-':
						weight = 1.67;
						break;
					case 'D+':
						weight = 1.33;
						break;
					case 'D':
						weight = 1;
						break;
					case 'D-':
						weight = 0.67;
						break;
					case 'F':
						weight = 0;
						break;
					default:
						weight = null;					
				}
				course.qualityPoints = weight * course.usCredits				

				switch(course.courseTerm)
				{
					case 'Fall':
						var fallQP = $filter('sumOfValueNotDropped')(app.fallCourses,'qualityPoints');
						var fallCredits = $filter('sumOfValueNotDropped')(app.fallCourses,'usCredits');
						app.fallGPA = fallQP / fallCredits;
						break;
					case 'Spring':
						var springQP = $filter('sumOfValueNotDropped')(app.springCourses,'qualityPoints');
						var springCredits = $filter('sumOfValueNotDropped')(app.springCourses,'usCredits');
						app.springGPA = springQP / springCredits;
						break;
					case 'Summer':
						var summerQP = $filter('sumOfValueNotDropped')(app.summerCourses,'qualityPoints');
						var summerCredits = $filter('sumOfValueNotDropped')(app.summerCourses,'usCredits');
						app.summerGPA = summerQP / summerCredits;
						break;
					default:
				}
			}			
			$scope.cancel = function(course){
				course.edit = false;
				$scope.viewModel.editMode = false;
				clearEditedLine();
			}
			$scope.cancelNewCourse = function(app){
				app.addCourse = false;
				clearAddNewCourse(app);
			}
			$scope.commitCourses = function(app, hostInst) {
				//VF Remoting to post the app viewModel back to controller to save in database
				courseRegistrationController.commitCourses(
					angular.toJson(app),
					function(result, event) {
						if(result) {
                            //alert(app.application.Name + " course registrations have been updated");
							app.hide = true;							
							app.host = app.application.Host_Institution__c;
							var host = $scope.viewModel.hostInstViewModels.indexOf(hostInst);
							for (var i = app.courseRegistrations.length - 1; i >= 0; i--) {
								if(app.courseRegistrations[i].isApproved == false) {
									app.hide = false;
								}
							}
							if(app.hide) {
								hostInst.applicationCourses.splice(hostInst.applicationCourses.indexOf(app), 1);
								if($scope.viewModel.hostInstViewModels[host].applicationCourses.length < 1) {
									$scope.viewModel.hostInstViewModels.splice(host, 1);
								}
							}
							$scope.$apply();
						}
						else {
							alert(app.application.Name + " course registrations have not been updated");
						}
				});
			}
			$scope.applicationGradesEntered = function(app, hostInst) {
				//VF Remoting to post the app viewModel back to controller to save in database
				courseRegistrationController.applicationGradesEntered(
					angular.toJson(app),
					$scope.viewModel.pageActionType,
					function(result, event) {
						if(result) {
                            //alert(app.application.Name + " course registrations have been updated");
							app.hide = true;							
							app.host = app.application.Host_Institution__c;
							var host = $scope.viewModel.hostInstViewModels.indexOf(hostInst);
							for (var i = app.courseRegistrations.length - 1; i >= 0; i--) {
								if(app.courseRegistrations[i].isApproved == false || app.courseRegistrations[i].isDropped == false) {
									app.hide = false;
								}
							}
							if(app.hide) {
								hostInst.applicationCourses.splice(hostInst.applicationCourses.indexOf(app), 1);
								if($scope.viewModel.hostInstViewModels[host].applicationCourses.length < 1) {
									$scope.viewModel.hostInstViewModels.splice(host, 1);
								}
							}
							$scope.$apply();
						}
						else {
							alert(app.application.Name + " course registrations have not been updated");
						}
				});
			}
			$scope.generateGradeDocuments = function() {
				$scope.message = 'Generating documents for Butler Grade Report...';
				var pageVM = angular.toJson($scope.viewModel)
				courseRegistrationController.generateGradeDocuments(
					pageVM,
					function(result, event) {
						//We want this to go to the default branch because that means the record Id was returned instead of an error message;
						if(result['jobId'])
						{
							$scope.checkJobCount = 0;
							$scope.message = 'Enqueued job to create Grade Report Records';
							$scope.checkJobStatus(result);
							$scope.viewModel.hostInstViewModels = [];
						}
						else
						{
							$scope.message = result['messages'];
						}
						$scope.$apply();
					}
				);
			}

			$scope.checkJobStatus = function(job) {
				$scope.checkJobCount = $scope.checkJobCount + 1;
				courseRegistrationController.checkJobStatus(
					job['jobId'],
					function(result) {
						switch (result) {
							case 'Holding':
							case 'Queued':
								$scope.message = 'Enqueued job to create Grade Report Records';
								$timeout(function() {$scope.checkJobStatus(job);}, 10000);
								break;
							case 'Preparing':
								$scope.message = 'Preparing job to create Grade Report Records';
								$timeout(function() {$scope.checkJobStatus(job);}, 10000);
								break;
							case 'Processing':
								$scope.message = 'Processing job to create Grade Report Records';
								$timeout(function() {$scope.checkJobStatus(job);}, 10000);
								break;
							case 'Completed':
								$scope.message = 'Create Grade Report Records job competed successfully';
								$scope.savedBGRId = job['bgrId'];
								$scope.viewModel.hostInstViewModels = [];
								break;
							case 'Aborted':
							case 'Failed':
								$scope.message = 'Job to failed create Grade Report Records';
								break;
							default:
								break;
						}
						$scope.$apply();
					}
				)
			}

			//Search for host instituiton
			$scope.searchForHostInstitutions = function(searchedHostInstitution) {
				courseRegistrationController.searchForRecord(
					'Host_Institution__c',
					searchedHostInstitution,
					function(result, event) {
						$scope.populateHostInstitutionDropdown(result, event);
					}
				);
			}

			//Once host institution results have come back, populate
			$scope.populateHostInstitutionDropdown = function(result, event) {
				$scope.hostInstitutionResults = result;
				$scope.$apply();
			}

			//Select a host institution
			$scope.selectHostInstitution = function(item, application) {
				application.addedCourse.searchedHostInstitutionId = item.id;
				//$scope.viewModel.hostInstitution.hostInstitutionId = item.id;
				item.name = item.name.replace(/&#39;/g, "'");				
				application.addedCourse.searchedHostInstitution = item.name;
			}

			//Search for courses
            $scope.searchForCourses = function(institutionId, searchTerm, fieldName) {
                courseRegistrationController.searchForCourses(
                    institutionId,
					searchTerm,
					fieldName,
                    function(result, event) {
                        $scope.populateCourseDropdown(result, event);
                    }
                );
			}

            //Once course results have come back, populate
            $scope.populateCourseDropdown = function(result, event) {
                $scope.courseResults = result;
                $scope.$apply();
            }

            //Select a course
            $scope.selectCourse = function(item, app) {
                var institutionId = app.addedCourse.searchedHostInstitutionId;
                var institutionName = app.addedCourse.searchedHostInstitution;
                item.departmentCode = item.departmentCodeString;
                app.addedCourse = item;                
                if(item.encodedCourseName)
                {
                    app.addedCourse.Name = item.encodedCourseName.replace("IFSA_ampSymbol_IFSA", "&");
                    //app.addedCourse.Title = item.encodedCourseTitle.replace("IFSA_ampSymbol_IFSA". "&");
                    app.addedCourse.courseName = app.addedCourse.Name;
                    app.addedCourse.courseTitle = app.addedCourse.courseTitle;
                }
                else
                {
                    app.addedCourse.encodedCourseName = item.courseName;
                    app.addedCourse.encodedCourseTitle = item.courseTitle;
                }
                app.addedCourse.searchedHostInstitutionId = institutionId;
                app.addedCourse.searchedHostInstitution = institutionName;                
            }
			clearEditedLine();
            
		});