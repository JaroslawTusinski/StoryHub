({
    doLoad: function(component, event) {
      var map = L.map('map', {zoomControl: true, tap: false})
                  .setView([0, 0], 2);
      L.tileLayer(
       'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
       {
              attribution: 'Tiles © Esri'
       }).addTo(map);
      component.set("v.map", map);
    },

    createMapMarks : function(component, event) {
        let listOfIDs = event.getParam('accountsIDs');

        if (listOfIDs && listOfIDs.length > 0) {
            let searchAccountsToMarkByID = component.get('c.searchAccountByID');

            if (searchAccountsToMarkByID) {
                searchAccountsToMarkByID.setParams({
                    accountsIDs : listOfIDs
                });

                searchAccountsToMarkByID.setCallback(this, function(response) {
                    this.accountSearchCallback(component, response);
                });

                $A.enqueueAction(searchAccountsToMarkByID);
            }
            else {
                console.error("'searchAccountByID' does not exist");
            }
        }
        else {
            let map = component.get('v.map');

            this.clearMarks(map, component.get('v.currentMarkers'));

            map.setView([0, 0], 2);
        }
    },

    accountSearchCallback : function(component, response) {
        let state = response.getState();

        if (state === 'SUCCESS') {
            this.markOnMap(component, response.getReturnValue());
        }
        else {
            let errors = response.getError();

            this.handleErrors(errors);
        }
    },

    markOnMap : function(component, searchResults) {
        let map = component.get('v.map');
        let currentMarkers = component.get('v.currentMarkers');
        let country;
        let city;
        let street;
        let http;
        let cityJSON;
        let marker;
        let i = 0;
        let latCenter = 0;
        let lonCenter = 0;

        this.clearMarks(map, currentMarkers);

        searchResults.forEach(function(branch) {
            country = branch.ShippingCountry || branch.BillingCountry || '';
            city = branch.ShippingCity || branch.BillingCity || '';
            street = branch.ShippingStreet || branch.BillingStreet || '';
            http = new XMLHttpRequest();

            http.open("GET", 'https://nominatim.openstreetmap.org/search?format=json&q=' + city + ' ' + country + ' ' + street, true);
            http.send();

            http.onreadystatechange = function() {
                if (this.readyState == 4 && this.status == 200) {
                    cityJSON = JSON.parse(this.responseText)[0];
                    marker = L.marker([cityJSON.lat, cityJSON.lon]).bindPopup(branch.Name + '<br/>' + cityJSON.display_name);
                    latCenter += parseFloat(cityJSON.lat);
                    lonCenter += parseFloat(cityJSON.lon);
                    i++;

                    marker.addTo(map);
                    currentMarkers.push(marker);

                    if (searchResults.length === 1) {
                        map.setView([cityJSON.lat, cityJSON.lon], 8);
                    }
                    if (searchResults.length === i) {
                        if (i != 1) {
                            map.setView([latCenter / i, lonCenter / i], 2);
                        }

                        component.set('v.currentMarkers', currentMarkers);
                    }
                }
            }
        });
    },

    clearMarks : function(map, currentMarkers) {
        if (currentMarkers) {
            currentMarkers.forEach(function(mark) {
                map.removeLayer(mark);
            });
        }
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
})