({
    jsLoaded : function(component, event, helper) {
        helper.doLoad(component, event);
    },

    handleSendSelectedBranchIDEvent : function(component, event, helper) {
        helper.createMapMarks(component, event);
    },

    handleSendInfoAfterAccountUpsertEvent : function(component, event, helper) {
        helper.createMapMarks(component, event);
    },
})