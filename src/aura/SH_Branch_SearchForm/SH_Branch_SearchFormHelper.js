({
    doSetSearchParametersForSearchCredentialsEvent : function(component, event) {
        let SearchCredentials = {
            country : component.get('v.inputCountryName') || '',
            city : component.get('v.inputCityName') || ''
        };

        this.fireAppEvent(SearchCredentials, true);
    },

    doClearSearchParametersForSearchCredentialsEvent : function(component, event) {
        let SearchCredentials = {
            country : '',
            city : ''
        };

        component.set('v.inputCityName', undefined);
        component.set('v.inputCountryName', undefined);

        this.fireAppEvent(SearchCredentials, false);
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