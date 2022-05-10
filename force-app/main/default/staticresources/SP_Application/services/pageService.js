/**
 * Student Portal Page Service
 * @file Chart Page Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('pageService', function($window, $filter) {
    let defaultTitle;
    return {
        setTitle: function (newTitle) {
            if(newTitle != null && newTitle != ''){
                $window.document.title = newTitle + ' - ' + defaultTitle;
            }
        },
        setDefaultTitle: function(title){
            if(title != null && title != ''){
                title = $filter('apostraphe')(title);
                title = $filter('ampersand')(title);
                title = $filter('quote')(title);
                defaultTitle = title;
                $window.document.title = title;   
            }
        }
     };
});