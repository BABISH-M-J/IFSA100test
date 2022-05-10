/**
 * Text Replace Filters
 * @file Text Replace Filters
 * @copyright 2020 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.1
 */

angular.module('ifsa.common')
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
})
.filter('replace', [function () {

    return function (input, from, to) {
    
    if(input === undefined || input === null) {
        return;
    }

    var regex = new RegExp(from, 'g');
    return input.replace(regex, to);
    
    };
}]);