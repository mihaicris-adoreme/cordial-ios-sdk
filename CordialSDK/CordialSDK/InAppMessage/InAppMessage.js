// Init head variable
var head = document.head || document.getElementsByTagName('head')[0];

// Disable users selecting text in WKWebView
var style = document.createElement('style');
style.type = 'text/css';
style.appendChild(document.createTextNode('*{-webkit-touch-callout:none;-webkit-user-select:none}'));
head.appendChild(style);
