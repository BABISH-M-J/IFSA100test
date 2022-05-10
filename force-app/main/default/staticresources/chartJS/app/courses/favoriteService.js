/**
 * Chart Favorite Service
 * @file Chart Favorite Service
 * @copyright 2019 Institute for Study Abroad
 * @author Jay Holt <jholt@ifsa-butler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('favoriteService', function($q, $timeout, viewModel) {
    
    var self = this;
    var favorites = [];

    // Returns the favorites array (Favorites is populated when CHART initializes, and then manipulated by the user via the UI by favoriting and/or unfavoriting)
    this.getFavorites = function()
    {
        return favorites;
    }

    // Adds a favorite record to the 'favorites' array, not to the database. (Use updateFavorite to add to database first, then use this if successful)
    this.addFavorite = function(favorite)
    {
        favorites.push(favorite);
    }
    
    // Removes a favorite record from the 'favorites' array, not the database. (Use updateFavorite to remove from database first, then use this if successful)
    this.removeFavorite = function(favoriteId)
    {
        var index = favorites.indexOf(favorites.find(c => c.Id === favoriteId));
        if(index > -1){
            favorites.splice(index, 1);
        }
    }

    // Get favorites from the database
    this.loadFavorites = function()
    {
        favorites = [];
        var deferred = $q.defer();
        chartRemoteMethods.getFavorites(
            function(result) {
                if(result && result.success){
                    favorites = favorites.concat(result.payload);
                    deferred.resolve(result.payload);
                }
                else{
                    deferred.reject(result);
                }
        });
        return deferred.promise;
    }

    // Method for creating a new favorite or deleting an existing favorite from the database
    this.updateFavorite = function(contactId, course)
    {
        contactId = contactId;
        courseId = course.recordId;
        favoriteId = course.favoriteId;
        isFavorite = course.isFavorite;

        var deferred = $q.defer();
        chartRemoteMethods.updateFavorite(
            contactId, courseId, favoriteId, isFavorite,
            function(result) {
                if(result.success){
                    // do something with the results
                    if(result.payload){
                        // add fav
                        self.addFavorite(result.payload);
                    } else {
                        // remove fav
                        self.removeFavorite(favoriteId);
                    }
                    deferred.resolve(result);
                }
                else{
                    deferred.reject(result);
                }
        });
        return deferred.promise;
    }

    // Checks to see if a course is a favorite or not, returns the favorite record if so
    this.checkFavorite = function(courseId)
    {
        var fav = favorites.find(f => f.Course__c == courseId);
        if(fav){
            return fav;
        } else {
            return null;
        }
    }
});