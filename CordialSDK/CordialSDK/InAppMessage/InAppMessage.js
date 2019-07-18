// Action function for user interaction with app
function buttonAction(deepLink = null, eventName = null) {
    try {
        webkit.messageHandlers.buttonAction.postMessage({
            deepLink: deepLink,
            eventName: eventName
        });
    } catch (error) {
        console.error(error);
    }
}

// Init head variable
var head = document.head || document.getElementsByTagName('head')[0];

// Disable users selecting text in WKWebView
var style = document.createElement('style');
style.type = 'text/css';
style.appendChild(document.createTextNode('*{-webkit-touch-callout:none;-webkit-user-select:none}'));
head.appendChild(style);
