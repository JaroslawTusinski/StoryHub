({
    doSetSearchParametersForSearchCredentialsEvent : function(component, event) {
        let searchCredentials = this.setCredentialObjectParameters(component.get('v.inputCountryName') || '', component.get('v.inputCityName') || '');

        this.fireAppEvent(searchCredentials, true);
    },

    doClearSearchParametersForSearchCredentialsEvent : function(component, event) {
        let searchCredentials = this.setCredentialObjectParameters('', '');

        component.set('v.inputCityName', undefined);
        component.set('v.inputCountryName', undefined);

        this.fireAppEvent(searchCredentials, false);
    },

    setCredentialObjectParameters : function (country, city) {
        let searchCredentials = {
            country : country,
            city : city
        };

        return searchCredentials;
    },

    fireAppEvent : function(credentialsObject, isSearchAction) {
        let appSearchCredentialsEvent = $A.get('e.c:SH_Branch_SearchCredentialsEvent');

        appSearchCredentialsEvent.setParams({
            'searchCredentialsObject' : credentialsObject,
            'isSearchAction' : isSearchAction
        });

        appSearchCredentialsEvent.fire();
    }
})