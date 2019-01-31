({
    removeCredential : function(component, event) {
        const credentialKey = (event.currentTarget).dataset.key;
        let searchCredentialsObject = component.get('v.searchCredentialsObject');
        let searchCredentials = component.get('v.searchCredentials');

        if (credentialKey && searchCredentialsObject && searchCredentials) {
            let i = 0;
            searchCredentialsObject[credentialKey] = '';

            while(searchCredentials[i].key != credentialKey) {
                i++;
            }

            searchCredentials.splice(i, 1);
            component.set('v.searchCredentials', searchCredentials);
        }

        return searchCredentialsObject;
    },

    searchNewResults : function(component, event) {
        this.switchSpinner(component, true);

        let newCredentialsObject = this.removeCredential(component, event);

        component.set('v.searchCredentialsObject', newCredentialsObject);
        this.searchAccountByCredentials(component, newCredentialsObject, true);
    },

    setSearchResults : function(component, event) {
        this.switchSpinner(component, true);

        if (event.getParam('isSearchAction')) {
            let searchCredentialsObject = JSON.parse(JSON.stringify(event.getParam('searchCredentialsObject')));

            component.set('v.searchCredentialsObject', searchCredentialsObject);

            this.setFilters(component, searchCredentialsObject);
            this.searchAccountByCredentials(component, searchCredentialsObject, true);
        }
        else {
            component.set('v.isResultBodyNotEmpty', false);
            component.set('v.searchCredentials', null);
            this.switchSpinner(component, false);
            this.prepareAccountsIDsToDisplayEvent(component, null, true);
        }
    },

    researchAccounts : function(component, event, resetMapMarks) {
        let searchCredentialsObject = component.get('v.searchCredentialsObject');

        this.searchAccountByCredentials(component, searchCredentialsObject, resetMapMarks);
    },

    setFilters : function(component, searchCredentialsObject) {
        let keysOfSearchCredentialsObject = Object.keys(searchCredentialsObject);
        let searchCredentials = [];

        keysOfSearchCredentialsObject.forEach(function(keyOfCredential) {
            if (searchCredentialsObject[keyOfCredential] != '') {
                let filterObject = {
                    value : ($A.get('$Label.c.' + 'Search_label_' + keyOfCredential) + ' ' + searchCredentialsObject[keyOfCredential]),
                    key : keyOfCredential
                };

                searchCredentials.push(filterObject);
            }
        });

        component.set('v.searchCredentials', searchCredentials);
    },

    searchAccountByCredentials : function(component, searchCredentialsObject, resetMapMarks) {
        let searchAccountByCredentialsObject = component.get('c.searchAccountByCredentialsObject');

        if (searchAccountByCredentialsObject) {
            searchAccountByCredentialsObject.setParams({
                credentialsObjectJSON : JSON.stringify(searchCredentialsObject)
            });

            searchAccountByCredentialsObject.setCallback(this, function(response) {
                this.accountSearchCallback(component, response, resetMapMarks);
            });

            $A.enqueueAction(searchAccountByCredentialsObject);
        }
        else {
            console.error("'searchAccountByCredentialsObject' does not exist");
        }
    },

    accountSearchCallback : function(component, response, resetMapMarks) {
        let state = response.getState();

        if (state === 'SUCCESS') {
            this.prepareResultsToDisplay(component, response.getReturnValue(), resetMapMarks);
        }
        else {
            let errors = response.getError();

            this.handleErrors(errors);
        }

        this.switchSpinner(component, false);
    },

    prepareResultsToDisplay : function(component, searchResults, resetMapMarks) {
        component.set('v.searchResults', searchResults);
        component.set('v.isResultBodyNotEmpty', (searchResults.length > 0));
        this.prepareAccountsIDsToDisplayEvent(component, searchResults, resetMapMarks);
    },

    handleErrors : function(errors) {
        // TODO - needs to be put in utils class

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

    doSelectBranch : function(component, event) {
        let selectedBranchId = (event.currentTarget).dataset.id;
        let listOfBranches = component.get('v.searchResults');
        const rowSelected = 'row-selected';

        listOfBranches.forEach(function(branch) {
            if (branch.Id != selectedBranchId) {
                document.getElementById(branch.Id).classList.remove(rowSelected);
            }
            else {
                document.getElementById(selectedBranchId).classList.add(rowSelected);
            }
        });

        this.prepareAccountsIDsToDisplayEvent(component, selectedBranchId, true);
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

    prepareAccountsIDsToDisplayEvent : function(component, searchResults, resetMapMarks) {
        let appAccountsIDsToDisplayEvent = $A.get('e.c:SH_Branch_AccountsIDsToDisplay');
        let listOfIDs = [];

        if (resetMapMarks) {
            if (typeof(searchResults) === 'string') {
                listOfIDs.push(searchResults);
                component.set('v.selectID', searchResults);
            }
            else if (searchResults) {
                searchResults.forEach(function(account) {
                    listOfIDs.push(account.Id);
                });
            }
        }
        else {
            listOfIDs.push(component.get('v.selectID'));
        }

        appAccountsIDsToDisplayEvent.setParam('accountsIDs', listOfIDs);
        appAccountsIDsToDisplayEvent.fire();
    },
})