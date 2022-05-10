angular.module('app.controllers')
.filter('apostraphe', function(){
    return function(input){
        input = input ? input.replace(/&39;/g, "'") : '';
        return input.replace(/&amp;#39;/g, "'");
    }
})

.filter('ampersand', function(){
    return function(input){
        input = input ? input.replace(/&amp;/g, "&") : '';
        return input.replace(/&amp;amp;/g, "&");
    }
})

.filter('quote', function(){
    return function(input){
        input = input ? input.replace(/&quot;/g, '"') : '';
        return input.replace(/&amp;quot;/g, '"');
    }
})
.filter('semicolon', function(){
    return function(input){
        return input ? input.replace(/;/g, ", ") : ""; 
    }
})
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