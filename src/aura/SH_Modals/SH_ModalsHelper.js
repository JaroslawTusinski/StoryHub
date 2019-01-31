({
    doDeleteModalVisibility : function(component, event) {
        let args = event.getParam('arguments');

        if (args) {
            let objectID = args.objectID;
            let secondObjectID = args.secondObjectID;
            let objectName = args.objectName;

            if (args.isVisibility) {
                component.set('v.objectType', objectName);
                component.set('v.objectID', objectID);
                component.set('v.secondObjectID', secondObjectID);
                component.set('v.isDeleteModalOpen', true);
            }
        }
        else {
            console.error("'args' does not exist");
        }
    },

    doDelete : function(component, event) {
        const deleteObjectByCredentials = component.get('c.deleteObjectByID');

        if (deleteObjectByCredentials) {
            let objectID = component.get('v.objectID');
            let secondObjectID = component.get('v.secondObjectID');
            let objectName = component.get('v.objectType');

            deleteObjectByCredentials.setParams({
                objectID : objectID,
                secondObjectID : secondObjectID,
                objectName : objectName
            });

            deleteObjectByCredentials.setCallback(this, function(response) {
                this.deleteCallback(component, response);
            });

            $A.enqueueAction(deleteObjectByCredentials);
        }
        else {
            console.error("'deleteObjectByID' does not exist");
        }
    },

    deleteCallback : function(component, response) {
        let state = response.getState();

        if (state === 'SUCCESS') {
            let appEvent = $A.get('e.c:SH_SendInfoAfterAccountUpsertEvent');
            let objID = [];

            objID.push(component.get('v.objectID'));

            appEvent.setParams({
                accountsIDs : objID
            });

            appEvent.fire();
            this.handleSuccess();
        }
        else {
            let errors = response.getError();

            this.handleErrors(errors);
        }

        component.set('v.isDeleteModalOpen', false);
        this.switchSpinner(component, false);
    },

    doAddModalVisibility : function(component, event) {
        let args = event.getParam('arguments');

        if (args) {
            this.switchSpinner(component, true);

            let objectID = args.objectID;
            let objectName = args.objectName;

            if (args.isVisibility) {
                component.set('v.objectType', objectName);
                component.set('v.objectID', objectID);
                component.set('v.isAddModalOpen', true);
                this.searchObjects(component, objectID);
            }
        }
        else {
            console.error("'args' does not exist");
        }
    },

    searchObjects : function(component, objectID) {
        let searchObjectByCredential = component.get('c.searchEmployees');

        if (searchObjectByCredential) {
            searchObjectByCredential.setParams({
                accountID : objectID
            });

            searchObjectByCredential.setCallback(this, function(response) {
                let state = response.getState();
                if (state === 'SUCCESS') {
                    component.set('v.objectListToDisplay', response.getReturnValue());
                }
                else {
                    let errors = response.getError();

                    this.handleErrors(errors);
                }

                this.switchSpinner(component, false);
            });

            $A.enqueueAction(searchObjectByCredential);
        }
        else {
            console.error("'searchEmployees' does not exist");
        }
    },

    doEditModalVisibility : function(component, event) {
        let args = event.getParam('arguments');

        if (args) {
            let objectID = args.objectID;
            let objectName = args.objectName;

            this.switchSpinner(component, true);

            if (args.isVisibility) {
                component.set('v.isEditModalOpen', true);
                component.set('v.objectType', objectName);
                component.set('v.objectID', objectID);
                this.searchObject(component, objectID, objectName);
            }
        }
        else {
            console.error("'args' does not exist");
        }
    },

    searchObject : function(component, objectID, objectName) {
        let searchObjectByCredentials = component.get('c.searchObjectByID');


        if (searchObjectByCredentials) {
            searchObjectByCredentials.setParams({
                objectID : objectID,
                objectName : objectName
            });

            searchObjectByCredentials.setCallback(this, function(response) {
                this.searchCallback(component, response);
            });

            searchObjectByCredentials.setStorable();
            $A.enqueueAction(searchObjectByCredentials);
        }
        else {
            console.error("'searchObjectByID' does not exist");
        }
    },

    searchCallback : function(component, response) {
        let state = response.getState();

        if (state === 'SUCCESS') {
            component.set('v.objectListToDisplay', JSON.parse(response.getReturnValue()));
        }
        else {
            let errors = response.getError();

            this.handleErrors(errors);
        }

        this.switchSpinner(component, false);
    },

    doCancel : function(component, event) {
        component.set('v.isEditModalOpen', false);
        component.set('v.isDeleteModalOpen', false);
        component.set('v.isAddModalOpen', false);
    },

    doSave : function(component, event) {
        this.switchSpinner(component, true);

        let saveObject = component.get('c.saveObject');

        if (saveObject) {
            let objJSON = JSON.stringify(component.get('v.objectListToDisplay'));
            let objName = component.get('v.objectType');
            let objID = component.get('v.objectID');

            saveObject.setParams({
                objectJSON : objJSON,
                objectName : objName,
                objectID : objID
            });

            saveObject.setCallback(this, function(response) {
                this.saveCallback(component, event, response);
            });

            $A.enqueueAction(saveObject);
        }
        else {
            console.error("'saveObject' does not exist");
        }
    },

    saveCallback : function(component, event, response) {
        let state = response.getState();

        if (state === 'SUCCESS') {
                let appEvent = $A.get('e.c:SH_SendInfoAfterAccountUpsertEvent');
                let objID = [];

                objID.push(component.get('v.objectID'));

                appEvent.setParams({
                    accountsIDs : objID
                });

                appEvent.fire();

            this.handleSuccess();
        }
        else {
            let errors = response.getError();

            this.handleErrors(errors);
        }

        this.doCancel(component, event);
        this.switchSpinner(component, false);
    },

    doAddEmployeeToAccount : function(component, event) {
        this.switchSpinner(component, true);

        let addObject = component.get('c.addRelationEmployeeAndAccount');

            if (addObject) {

            let accountID = component.get('v.objectID');
            let userID = (event.currentTarget).dataset.id;

            addObject.setParams({
                accountID : accountID,
                userID : userID
            });

            addObject.setCallback(this, function(response) {
                this.saveCallback(component, event, response);
            });

            $A.enqueueAction(addObject);
        }
        else {
            console.error("'addRelationEmployeeAndAccount' does not exist");
        }
    },

    returnSaveState : function(component, event) {
        return component.get('v.isEditModalOpen');
    },

    handleSuccess : function() {
        let toastParams = {
            title: $A.get('$Label.c.Save_success_message_title'),
            message: $A.get('$Label.c.Save_success_message'),
            type: "success"
        };

        let toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },

    handleErrors : function(errors) {
        let errorMessage = 'Unknown error';

        if (errors && Array.isArray(errors) && errors.length > 0) {
            errorMessage = errors[0].message;
        }

        let toastParams = {
            title: $A.get('$Label.c.Error_message_title'),
            message: $A.get('$Label.c.Error_message'),
            type: "error"
        };

        let toastEvent = $A.get("e.force:showToast");

        console.error(errorMessage);
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },

    switchSpinner : function(component, status) {
        const spinnerComponent = component.find('spinner');

        if (spinnerComponent) {
            spinnerComponent.switchSpinner(status);
        }
        else {
            console.error("'spinner' does not exist");
        }
    },
})