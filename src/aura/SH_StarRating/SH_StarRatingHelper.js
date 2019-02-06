({
    doChange : function(component, event, helper) {
            let currentProductID = component.get('v.productID');
            let productRate = component.get('c.getAverageRating');

            productRate.setParams({
                'productID' : currentProductID
            });

            productRate.setCallback(this, function(response) {
                let state = response.getState();

                if (state === 'SUCCESS') {
                    let opinions = response.getReturnValue();

                    if (opinions) {
                        helper.setRateAttributes(component, opinions);
                    }
                }
                else {
                    // TODO
                }
            });

            $A.enqueueAction(productRate);
    },

    setRateAttributes : function(component, opinions) {
        let i = 0;
        opinions.forEach(function(optionRate){
            if (optionRate!= null) {
                if (i == 0){
                    component.set('v.rate', optionRate);
                }
                else if (i == 1){
                    component.set('v.usersNumber', optionRate);
                }
                else if (i == 2){
                    component.set('v.averageRating', optionRate);
                }
            }
            else {
                if (i == 0){
                    component.set('v.rate', 0);
                }
                else if (i == 1){
                    component.set('v.usersNumber', 0);
                }
                else if (i == 2){
                    component.set('v.averageRating', 0);
                }
            }

            ++i;
        });
    },

    switchSpinner : function(component, status) {
        const spinnerComponent = component.find('spinner');

        if (spinnerComponent) {
            spinnerComponent.switchSpinner(status);
        }
    },

    doStarHover : function(component, event, status) {
        let value = (event.currentTarget).dataset.value;

        while (value != '0') {
            let starPart = document.getElementById('r' + value);

            if (status) {
                $A.util.addClass(starPart, 'star-hover');
            }
            else {
                $A.util.removeClass(starPart, 'star-hover');
            }

            value -= 10;
        }
    },

    doSaveValue : function(component, event) {
        let value = parseInt((event.currentTarget).dataset.value);
        let productRate = component.get('c.saveRate');
        let currentProductID = component.get('v.productID');

        component.set('v.rate', value);

        productRate.setParams({
            'rate' : value,
            'productID' : currentProductID
        });

        productRate.setCallback(this, function(response) {
            let state = response.getState();

            if (state === 'SUCCESS') {
                let opinions = response.getReturnValue();

                if (opinions) {
                    this.setRateAttributes(component, opinions);

                    let toastParams = {
                        title: 'Success',
                        message: 'Your rate has been saved',
                        type: "success"
                    };

                    let toastEvent = $A.get("e.force:showToast");

                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                }
            }
            else {
                let toastParams = {
                    title: 'Error',
                    message: 'Your rate has not been saved',
                    type: "error"
                };

                let toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        });

        $A.enqueueAction(productRate);

        for (var i = 100; i > value; i -= 10) {
            let starPart = document.getElementById('r' + i);

            $A.util.removeClass(starPart, 'star-point');
        }

        while (value != 0) {
            let starPart = document.getElementById('r' + value);

            $A.util.addClass(starPart, 'star-point');

            value -= 10;
        }
    },
})