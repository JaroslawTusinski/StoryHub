({
    init: function(component, event, helper) {
        helper.doInit(component, event);
    },

    checkMinAndMax: function(component, event, helper) {
        helper.doCheckValid(component, event, true);
    },

    slideMoreCredentials: function(component, event, helper) {
        helper.doSlideMoreCredentials(component, event);
    },

    slideClearCredentials: function(component, event, helper) {
        helper.doSlideClearCredentials(component, event, true);
    },

    categoryChange: function(component, event, helper) {
        helper.doSlideClearCredentials(component, event, false);
    },

    handleSearch : function(component, event, helper) {
        helper.doHandleSearch(component, event);
    },
})