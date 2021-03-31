// Action function for user interaction with app
function crdlAction(deepLink = null, eventName = null) {
   try {
       webkit.messageHandlers.crdlAction.postMessage({
           deepLink: deepLink,
           eventName: eventName
       });
   } catch (error) {
       console.error(error);
   }
}

