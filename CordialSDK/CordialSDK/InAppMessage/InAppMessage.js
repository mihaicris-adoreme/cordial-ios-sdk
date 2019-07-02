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
