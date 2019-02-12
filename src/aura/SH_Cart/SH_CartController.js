({
    init: function(component, event, helper) {
        helper.doInit(component, event);
    },

    showItems : function(component, event, helper) {
        helper.doShowItems(component, event);
    },

    onAddProductToCart: function(component, event, helper) {
        helper.doAddProductToCart(component, event);
    },

    addMoreItems: function(component, event, helper) {
        helper.changeNumberOfItem(component, event, true);
    },

    lessItems: function(component, event, helper) {
        helper.changeNumberOfItem(component, event, false);
    },

    goToOrder: function(component, event, helper) {
        let navEvt = $A.get('e.force:navigateToURL');

        navEvt.setParams({url: '/order'});
        navEvt.fire();
    },
})