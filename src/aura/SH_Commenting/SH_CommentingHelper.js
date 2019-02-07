({
    doSendComment : function(component, event) {
        let productOpinion = component.get('c.saveComment');
        let currentComment = component.get('v.comment');
        let productID = component.get('v.productID');

        productOpinion.setParams({
            'userComment' : currentComment,
            'productID' : productID,
        });

        productOpinion.setCallback(this, function(response) {
            let state = response.getState();

            if (state === 'SUCCESS') {
                let opinions = response.getReturnValue();

                component.set('v.usersComments', response.getReturnValue());
                component.set('v.comment', '');

                if (response.getReturnValue().length > 0) {
                    component.set('v.isCommentsExist', true);
                }
                else {
                    component.set('v.isCommentsExist', false);
                }

                let toastParams = {
                    title: 'Success',
                    message: 'Your comment has been saved',
                    type: "success"
                };

                let toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
            else {
                let toastParams = {
                    title: 'Error',
                    message: 'Your comment has not been saved',
                    type: "error"
                };

                let toastEvent = $A.get("e.force:showToast");

                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        });

        $A.enqueueAction(productOpinion);
    },

    doChange : function(component, event) {
        let productOpinion = component.get('c.getComment');
        let productID = component.get('v.productID');

        productOpinion.setParams({
            'productID' : productID
        });

        productOpinion.setCallback(this, function(response) {
            let state = response.getState();

            if (state === 'SUCCESS') {
                let opinions = response.getReturnValue();

                component.set('v.usersComments', response.getReturnValue());

                if (response.getReturnValue().length > 0) {
                    component.set('v.isCommentsExist', true);
                }
                else {
                    component.set('v.isCommentsExist', false);
                }

                this.switchSpinner(component, false);
            }
            else { }
        });

        $A.enqueueAction(productOpinion);
        this.switchSpinner(component, true);
    },

    switchSpinner : function(component, status) {
        const spinnerComponent = component.find('spinner');

        if (spinnerComponent) {
            spinnerComponent.switchSpinner(status);
        }
    },
})