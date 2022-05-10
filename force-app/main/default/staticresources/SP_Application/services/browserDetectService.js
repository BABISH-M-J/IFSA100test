/**
 * Student Portal Browser Detect Service
 * @file Student Portal Browser Detect Service
 * @copyright 2019 Institute for Study Abroad
 * @author Brock Barlow <bbarlow@ifsabutler.org> 
 * @version 2.0
 */
angular.module('app.services')
.service('browserDetectService', function() {
    var self = this;

    // Opera 8.0+
    var isOpera = (!!window.opr && !!opr.addons) || !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0;

    // Firefox 1.0+
    var isFirefox = typeof InstallTrigger !== 'undefined';

    // Safari 3.0+ "[object HTMLElementConstructor]" 
    var isSafari = /constructor/i.test(window.HTMLElement) || (function (p) { return p.toString() === "[object SafariRemoteNotification]"; })(!window['safari'] || (typeof safari !== 'undefined' && safari.pushNotification));

    // Internet Explorer 6-11
    var isIE = /*@cc_on!@*/false || !!document.documentMode;

    // Edge 20+
    var isEdge = !isIE && !!window.StyleMedia;

    // Chrome 1 - 71
    var isChrome = !!window.chrome && (!!window.chrome.webstore || !!window.chrome.runtime);

    // Blink engine detection
    var isBlink = (isChrome || isOpera) && !!window.CSS;

    this.getBrowserName = function(){
        if(isChrome){
            return 'chrome';
        }
        else if(isFirefox){
            return 'firefox';
        }
        else if(isSafari){
            return 'safari';
        }
        else if(isIE){
            return 'ie';
        }
        else if(isEdge){
            return 'edge';
        }
        else if(isOpera){
            return 'opera';
        }
        
        return 'other';
    }
});