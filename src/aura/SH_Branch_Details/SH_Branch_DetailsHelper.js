({
    doDeleteAccount : function(component, event) {
        const modals = component.find('modals');

        if (modals) {
            const accountID = component.get('v.accountID');

            modals.setDeleteModalVisibility(accountID, '', 'Account', true);
        }
        else {
            console.error("'modals' does not exist");
        }
    },

    findDetails : function(component, event) {
        let accountsIDs = event.getParam('accountsIDs');

        if (accountsIDs && accountsIDs.length == 1) {
            let accountID = accountsIDs[0];

            component.set('v.accountID', accountID);
            this.setUserPermission(component);
            this.findDetailsToDisplay(component, accountID, true);
            this.findDetailsToDisplay(component, accountID, false);
        }
        else {
            component.set('v.isResultBodyNotEmpty', false);
        }
    },

    setUserPermission : function(component) {
        let permission = component.get('c.checkUserPermissionToDelete');

        if (permission) {
            permission.setCallback(this, function(response) {
                let state = response.getState();

                if (state === 'SUCCESS') {
                    component.set('v.userPermissionToDeleteButton', response.getReturnValue());
                }
                else {
                    let errors = response.getError();

                    this.handleErrors(errors);
                    component.set('v.userPermissionToDeleteButton', false);
                }
            });

            $A.enqueueAction(permission);
        }
        else {
            console.error("'permission' does not exist");
        }
    },

    findDetailsToDisplay : function(component, accountID, isAccount) {
        let searchAccountByID;

        if (isAccount) {
            searchAccountByID = component.get('c.getAccountByID');
        }
        else {
            searchAccountByID = component.get('c.searchEmployeesByAccountID');
        }

        if (searchAccountByID) {
            searchAccountByID.setParam('accountID', accountID);
            this.switchSpinner(component, true);

            searchAccountByID.setCallback(this, function(response) {
                this.searchCallback(component, response, isAccount);
            });

            $A.enqueueAction(searchAccountByID);
        }
        else {
            console.error("'searchAccountByID' is undefined");
        }
    },

    searchCallback : function(component, response, isAccount) {
        let state = response.getState();

        if (state === 'SUCCESS') {
            if (isAccount) {
                this.prepareAccountToDisplay(component, response.getReturnValue());
            }
            else {
                this.prepareEmployeeToDisplay(component, response.getReturnValue());
            }
        }
        else {
            console.error("state error - " + response.getReturnValue());
        }

        this.switchSpinner(component, false);
    },

    prepareAccountToDisplay : function(component, account) {
        let accountFields = Object.keys(account);
        let accountDetails = [];

        if (account) {
            accountFields.forEach(function(accountKey) {
                if (accountKey != 'Id') {
                    let accountObject = {
                        value : account[accountKey],
                        key : accountKey
                    }

                    accountDetails.push(accountObject);
                }
            });

            component.set('v.isResultBodyNotEmpty', false); // #lightning XD
            component.set('v.isResultBodyNotEmpty', true);
        }

        component.set('v.accountDetails', accountDetails);
    },

    prepareEmployeeToDisplay : function(component, employees) {
        let employeeFields;
        let listOfEmployees = [];
        let employeeObject;

        if (employees) {
            employees.forEach(function(employee) {
                employeeFields = Object.keys(employee);
                employeeObject = [];

                employeeFields.forEach(function(employeeKey) {
                    let partOfEmployeeObject = {
                        value : employee[employeeKey],
                        key : employeeKey
                    }

                    employeeObject.push(partOfEmployeeObject);
                });

                listOfEmployees.push(employeeObject);
            });
        }

        component.set('v.employeesNumber', ' ( ' + listOfEmployees.length + ' ) ');
        component.set('v.employees', listOfEmployees);
    },

    doEditAccount : function(component, event) {
        const modals = component.find('modals');

        if (modals) {
            const accountID = component.get('v.accountID');

            modals.setEditModalVisibility(accountID, 'Account', true);
        }
        else {
            console.error("'modals' does not exist");
        }
    },

    doEditEmployee : function(component, event) {
        const modals = component.find('modals');

        if (modals) {
            const employeeID = (event.currentTarget).dataset.value;
            const accountID = component.get('v.accountID');

            modals.setEditModalVisibility(employeeID, 'User', true);
            this.findDetailsToDisplay(component, accountID, false);
        }
        else {
            console.error("'modals' does not exist");
        }
    },

    doRemoveEmployee : function(component, event) {
        const modals = component.find('modals');

        if (modals) {
            const employeeID = (event.currentTarget).dataset.value;

            modals.setDeleteModalVisibility(component.get('v.accountID'), employeeID, 'Employee__c', true);
            this.findDetailsToDisplay(component, accountID, false);
        }
        else {
            console.error("'modals' does not exist");
        }
    },

    doAddEmployee : function(component, event) {
        const modals = component.find('modals');

        if (modals) {
            const accountID = component.get('v.accountID');

            modals.setAddModalVisibility(accountID, 'User', true);
            this.findDetailsToDisplay(component, accountID, false);
        }
        else {
            console.error("'modals' does not exist");
        }
    },

    switchSpinner : function(component, status) {
        const spinnerComponent = component.find('spinner');

        if (spinnerComponent) {
            spinnerComponent.switchSpinner(status);
        }
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
})