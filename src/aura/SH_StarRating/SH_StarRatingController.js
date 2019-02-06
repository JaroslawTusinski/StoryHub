({
    onChange : function(component, event, helper) {
        helper.doChange(component, event, helper);
    },

    onStarHover : function(component, event, helper) {
        helper.doStarHover(component, event, true);
    },

    onEndHover : function(component, event, helper) {
        helper.doStarHover(component, event, false);
    },

    saveValue : function(component, event, helper) {
        helper.doSaveValue(component, event);
    },
})