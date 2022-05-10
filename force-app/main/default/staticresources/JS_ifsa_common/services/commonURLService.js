/**
 * Common URL Service
 * @file Common URL Service
 * @copyright 2021 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsa-butler.org> 
 * @version 1.0
 */
 angular.module('ifsa.common')
.service('commonURLService', function() {
    var self = this;
    let spResourceURL;
    let apResourceURL;
    let chResourceURL;
    let letterheadURL;
    return {
        getSPResourceURL: function () {
            return spResourceURL;
        },
        getAPResourceURL: function () {
            return apResourceURL;
        },
        getCHResourceURL: function () {
            return chResourceURL;
        },
        getLetterheadURL: function () {
            return letterheadURL;
        },
        setSPResourceURL: function (value) {
            spResourceURL = value;
        },
        setAPResourceURL: function (value) {
            apResourceURL = value;
        },
        setCHResourceURL: function (value) {
            chResourceURL = value;
        },
        setLetterheadURL: function (value) {
            letterheadURL = value;
        }
    }
});