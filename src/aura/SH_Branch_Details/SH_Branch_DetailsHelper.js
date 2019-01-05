({
    doDeleteAccount : function(component, event) {
        const modal = component.find('modals');
        const accountID = component.get('v.accountID');

        modal.setDeleteModalVisibility(accountID, '', 'Account', true);
    },

    findDetails : function(component, event) {
        let accountsIDs = event.getParam('accountsIDs');

        if (accountsIDs === undefined || accountsIDs.length != 1) {
            component.set('v.isResultBodyNotEmpty', false);
        }
        else {
            let accountID = accountsIDs[0];

            component.set('v.accountID', accountID);
            this.getUserPermission(component);
            this.findDetailsToDisplay(component, accountID, true);
            this.findDetailsToDisplay(component, accountID, false);
        }
    },

    getUserPermission : function(component) {
        let permission = component.get('c.checkUserPermissionSet');

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
    },

    findDetailsToDisplay : function(component, accountID, isAccount) {
        let searchAccountByID;

        if (isAccount) {
            searchAccountByID = component.get('c.searchAccountByID');
        }
        else {
            searchAccountByID = component.get('c.searchEmployeesByAccountID');
        }

        searchAccountByID.setParam('accountID', accountID);
        this.switchSpinner(component, true);

        searchAccountByID.setCallback(this, function(response) {
            this.searchCallback(component, response, isAccount);
        });

        $A.enqueueAction(searchAccountByID);
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

        this.switchSpinner(component, false);
    },

    prepareAccountToDisplay : function(component, account) {
        let accountFields = Object.keys(account);
        let accountDetails = [];

        if (account != undefined) {
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

        if (employees != undefined) {
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
        const modal = component.find('modals');
        const accountID = component.get('v.accountID');

        modal.setEditModalVisibility(accountID, 'Account', true);
    },

    doEditEmployee : function(component, event) {
        const modal = component.find('modals');
        const employeeID = (event.currentTarget).dataset.value;
        const accountID = component.get('v.accountID');

        modal.setEditModalVisibility(employeeID, 'User', true);
        this.findDetailsToDisplay(component, accountID, false);
    },

    doRemoveEmployee : function(component, event) {
        const modal = component.find('modals');
        const employeeID = (event.currentTarget).dataset.value;

        modal.setDeleteModalVisibility(component.get('v.accountID'), employeeID, 'Employee__c', true);
        this.findDetailsToDisplay(component, accountID, false);
    },

    doAddEmployee : function(component, event) {
        const modal = component.find('modals');

        modal.setAddModalVisibility(component.get('v.accountID'), 'User', true);
        this.findDetailsToDisplay(component, accountID, false);
    },

    switchSpinner : function(component, status) {
        const spinnerComponent = component.find('spinner');

        spinnerComponent.switchSpinner(status);
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