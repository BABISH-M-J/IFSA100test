/**
 * Student Portal Replace Filters
 * @file Student Portal Replace Filters
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.filters')
.filter('apostraphe', function(){
	return function(input){
        input = input ? input.replace(/&#39;/g, "'") : '';
		return input ? input.replace(/&amp;#39;/g, "'") : '';
	}
})
.filter('ampersand', function(){
	return function(input){
        input = input ? input.replace(/&amp;/g, "&") : '';
		return input ? input.replace(/&amp;amp;/g, "&") : '';
	}
})
.filter('quote', function(){
	return function(input){
        input = input ? input.replace(/&quot;/g, '"') : '';
		return input ? input.replace(/&amp;quot;/g, '"') : '';
	}
})
.filter('nbsp', function(){
    return function(input){
		return input ? input.replace(/&amp;nbsp;/g, '&nbsp;') : '';
    }
})
// Fixes escaped HTML tags
.filter('fixHTMLTags', function() {
    return function(input) {
        if(input){
            input = input.replace(/&lt;/g, '<');
            input = input.replace(/&gt;/g, '>');
            input = input.replace(/&quot;/g, '"');
        }
        return input;
    }
});