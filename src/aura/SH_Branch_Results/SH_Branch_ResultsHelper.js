({
    removeCredentialAndSearchNewResults : function(component, event) {
        let searchCredentials = component.get('v.searchCredentials');
        let searchCredentialsObject = component.get('v.searchCredentialsObject');
        const credentialKey = (event.currentTarget).dataset.key;
        searchCredentialsObject[credentialKey] = '';
        let i = 0;

        this.switchSpinner(component, true);

        while(searchCredentials[i].key != credentialKey) {
            i++;
        }

        searchCredentials.splice(i, 1);
        component.set('v.searchCredentials', searchCredentials);
        component.set('v.searchCredentialsObject', searchCredentialsObject);
        this.searchAccountByCredentials(component, searchCredentialsObject, true);
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
            component.set('v.searchCredentials', undefined);
            this.switchSpinner(component, false);
            this.prepareAccountsIDsToDisplayEvent(component, undefined);
        }
    },

    researchAccounts : function(component, event) {
        let searchCredentialsObject = component.get('v.searchCredentialsObject');

        this.searchAccountByCredentials(component, searchCredentialsObject, false);
    },

    researchAccountsAndRunAgainOtherComponents : function(component, event) {
        let searchCredentialsObject = component.get('v.searchCredentialsObject');

        this.searchAccountByCredentials(component, searchCredentialsObject, true);
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

    searchAccountByCredentials : function(component, searchCredentialsObject, withStorable) {
        let searchAccountByCredentialsObject = component.get('c.searchAccountByCredentialsObject');
         if (!withStorable) {
            searchAccountByCredentialsObject = component.get('c.searchAccountByCredentialsObjectWithoutStorable');
        }

        searchAccountByCredentialsObject.setParams({
            credentialsObjectJSON : JSON.stringify(searchCredentialsObject)
        });

        searchAccountByCredentialsObject.setCallback(this, function(response) {
            this.accountSearchCallback(component, response, withStorable);
        });

        if (withStorable) {
            searchAccountByCredentialsObject.setStorable();
        }

        $A.enqueueAction(searchAccountByCredentialsObject);
    },

    accountSearchCallback : function(component, response, sendEvent) {
        let state = response.getState();

        if (state === 'SUCCESS') {
            this.prepareResultsToDisplay(component, response.getReturnValue(), sendEvent);
        }
        else {
            let errors = response.getError();

            this.handleErrors(errors);
        }

        this.switchSpinner(component, false);
    },

    prepareResultsToDisplay : function(component, searchResults, sendEvent) {
        component.set('v.searchResults', searchResults);
        component.set('v.isResultBodyNotEmpty', (searchResults.length > 0));
        this.prepareAccountsIDsToDisplayEvent(component, searchResults, sendEvent);
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

    doSelectBranch : function(component, event) {
        let selectedBranchId = (event.currentTarget).dataset.id;
        let listOfBranches = component.get('v.searchResults');

        listOfBranches.forEach(function(branch) {
            if (branch.Id != selectedBranchId) {
                document.getElementById(branch.Id).classList.remove('row-selected');
            }
            else {
                document.getElementById(selectedBranchId).classList.add('row-selected');
            }
        });

        this.prepareAccountsIDsToDisplayEvent(component, selectedBranchId, true);
    },

    switchSpinner : function(component, status) {
        const spinnerComponent = component.find('spinner');

        spinnerComponent.switchSpinner(status);
    },

    prepareAccountsIDsToDisplayEvent : function(component, searchResults, sendEvent) {
        if (sendEvent) {
            let appAccountsIDsToDisplayEvent = $A.get('e.c:SH_Branch_AccountsIDsToDisplay');
            let listOfIDs = [];

            if (typeof(searchResults) === 'string') {
                listOfIDs.push(searchResults);
            }
            else if (searchResults != undefined) {
                searchResults.forEach(function(account) {
                    listOfIDs.push(account.Id);
                });
            }

            appAccountsIDsToDisplayEvent.setParam('accountsIDs', listOfIDs);
            appAccountsIDsToDisplayEvent.fire();
        }
    },
})