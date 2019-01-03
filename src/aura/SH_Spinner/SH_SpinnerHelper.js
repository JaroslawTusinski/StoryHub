({
    doSwitchSpinner : function(component, event) {
        let argument = event.getParam('arguments');

        if (argument.status) {
            component.set('v.isSpinnerRun', true);
        }
        else {
            component.set('v.isSpinnerRun', false);
        }
    },
})