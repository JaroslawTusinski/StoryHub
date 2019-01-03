({
    handleSearchCredentialsEvent : function(component, event, helper) {
        helper.setSearchResults(component, event);
    },

    handleSendInfoAfterAccountUpsertEvent : function(component, event, helper) {
        helper.researchAccounts(component, event);
    },

    handleSendInfoAfterAccountDeleteEvent : function(component, event, helper) {
        helper.researchAccountsAndRunAgainOtherComponents(component, event);
    },

    removeCredential : function(component, event, helper) {
        helper.removeCredentialAndSearchNewResults(component, event);
    },

    selectBranch : function(component, event, helper) {
        helper.doSelectBranch(component, event);
    },
})