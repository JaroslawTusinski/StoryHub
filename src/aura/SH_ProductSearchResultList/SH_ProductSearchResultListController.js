({
    init: function(component, event, helper) {
        let productsJson = sessionStorage.getItem('customSearch--recordProducts');

        if (productsJson != 'null' && !$A.util.isUndefinedOrNull(productsJson)) {
            let products = JSON.parse(productsJson);
            component.set('v.Products', JSON.parse(productsJson));
            component.set('v.isNoResults', false);
            sessionStorage.removeItem('customSearch--recordProducts');

            console.log(products);
        }
        else {
            component.set('v.isNoResults', true);
        }
    },

    selectProduct : function(component, event, helper) {
        helper.doSelectProduct(component, event, true);
    },

    backToResults : function(component, event, helper) {
        helper.doSelectProduct(component, event, false);
    },
})