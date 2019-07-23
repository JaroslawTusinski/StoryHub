({
    backToHome : function(component, event, helper) {
        let navEvt = $A.get('e.force:navigateToURL');

        navEvt.setParams({url: '/'});
        navEvt.fire();
    },

    confirmOrder : function(component, event, helper) {
        helper.doConfirmOrder(component, event);
    },

    checkInputsValid : function(component, event, helper) {
        helper.doCheckInputsValid(component, event);
    },
})