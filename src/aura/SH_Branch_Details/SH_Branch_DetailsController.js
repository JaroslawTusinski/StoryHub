({
    handleSendSelectedBranchIDEvent : function(component, event, helper) {
        helper.findDetails(component, event);
    },

    handleSendInfoAfterAccountUpsertEvent : function(component, event, helper) {
        helper.findDetails(component, event);
    },

    editAccount : function(component, event, helper) {
        helper.doEditAccount(component, event);
    },

    deleteAccount : function(component, event, helper) {
        helper.doDeleteAccount(component, event);
    },

    editEmployee : function(component, event, helper) {
        helper.doEditEmployee(component, event);
    },

    removeEmployee : function(component, event, helper) {
        helper.doRemoveEmployee(component, event);
    },

    addEmployee : function(component, event, helper) {
        helper.doAddEmployee(component, event);
    },
})