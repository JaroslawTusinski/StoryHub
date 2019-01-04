({  // TODO - this component needs refactoring
    setEditModalVisibility : function(component, event, helper) {
        helper.doEditModalVisibility(component, event);
    },

    setDeleteModalVisibility : function(component, event, helper) {
        helper.doDeleteModalVisibility(component, event);
    },

    cancel : function(component, event, helper) {
        helper.doCancel(component, event);
    },

    save : function(component, event, helper) {
        helper.doSave(component, event);
    },

    deleteObject : function(component, event, helper) {
        helper.doDelete(component, event);
    },
})