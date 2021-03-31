// IAM action function for user interaction with app
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

// IAM action function for capture all HTML inputs
function crdlCaptureAllInputs(eventName = null) {
    if (eventName) {
        var inputs, index;
        var inputsMapping = {};

        inputs = document.getElementsByTagName('input');
        for (index = 0; index < inputs.length; ++index) {
            if (inputs[index].getAttribute('id')) {
                if (inputs[index].type === 'radio' || inputs[index].type === 'checkbox') {
                    inputsMapping[inputs[index].getAttribute('id')] = inputs[index].checked;
                } else {
                    inputsMapping[inputs[index].getAttribute('id')] = inputs[index].value;
                }
            }
        }

        selects = document.getElementsByTagName('select');
        
        for (index = 0; index < selects.length; ++index) {
            if (selects[index].getAttribute('id')) {
                inputsMapping[selects[index].getAttribute('id')] = selects[index].value;
            }
        }
           
        try {
            webkit.messageHandlers.crdlCaptureAllInputs.postMessage({
                inputsMapping: inputsMapping,
                eventName: eventName
            });
        } catch (error) {
            console.error(error);
        }
    }
}
