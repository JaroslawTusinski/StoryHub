({
    doConfirmOrder : function(component, event) {
        let insertNew = component.get('c.activeOrder');

        insertNew.setCallback(this, function(response) {
            let state = response.getState();

            if (state === 'SUCCESS') {
                let navEvt = $A.get('e.force:navigateToURL');

                navEvt.setParams({url: '/orderinfo'});
                navEvt.fire();
            }
            else {
                //TODO
            }
        });

        $A.enqueueAction(insertNew);
        this.switchSpinner(component, true);
    },

    doCheckInputsValid : function(component, event) {
        let shippingCountry = component.get('v.shippingCountry');
        let shippingStreet = component.get('v.shippingStreet');
        let shippingState = component.get('v.shippingState');
        let shippingPostalCode = component.get('v.shippingCode');
        let shippingCity = component.get('v.shippingCity');

        if (shippingCountry && shippingStreet && shippingState && shippingPostalCode && shippingCity) {
            component.set('v.formIsNotValid', false);
        }
        else {
            component.set('v.formIsNotValid', true);
        }
    },
})