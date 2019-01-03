({
    handleSendSelectedBranchIDEvent : function(component, event, helper) {
        helper.findDetails(component, event);
    },

    editAccount : function(component, event, helper) {
        helper.doEditAccount(component, event);
    },

    editEmployee : function(component, event, helper) {
        helper.doEditEmployee(component, event);
    },

    deleteAccount : function(component, event, helper) {
        helper.doDeleteAccount(component, event);
    },

    removeEmployee : function(component, event, helper) {
        helper.doRemoveEmployee(component, event);
    },

    handleSendInfoAfterAccountUpsertEvent : function(component, event, helper) {
        helper.findDetails(component, event);
    },
})