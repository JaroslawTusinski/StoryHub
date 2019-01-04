({
    handleSearchCredentialsEvent : function(component, event, helper) {
        helper.setSearchResults(component, event);
    },

    handleSendInfoAfterAccountUpsertEvent : function(component, event, helper) {
        helper.researchAccounts(component, event, false);
    },

    handleSendInfoAfterAccountDeleteEvent : function(component, event, helper) {
        helper.researchAccounts(component, event, true);
    },

    removeCredential : function(component, event, helper) {
        helper.searchNewResults(component, event);
    },

    selectBranch : function(component, event, helper) {
        helper.doSelectBranch(component, event);
    },
})