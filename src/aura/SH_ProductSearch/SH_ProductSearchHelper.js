({
    doInit: function(component, event) {
        const getAllPickListsValuesFromProduct = component.get('c.getAllPickListsValuesFromProduct');

        if (!getAllPickListsValuesFromProduct) return null;

        getAllPickListsValuesFromProduct.setCallback(this, function(response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const allPickListsValue = JSON.parse(response.getReturnValue());

                component.set('v.allBookGenre', this.generatePickListObject(allPickListsValue.allBookGenre));
                component.set('v.allMovieGenre', this.generatePickListObject(allPickListsValue.allMovieGenre));
                component.set('v.allBookType', this.generatePickListObject(allPickListsValue.allBookType));
                component.set('v.allMovieType', this.generatePickListObject(allPickListsValue.allMovieType));
                component.set('v.allConditions', this.generatePickListObject(allPickListsValue.allConditions));
            }
            else {
                console.error(status);
            }
        });

        $A.enqueueAction(getAllPickListsValuesFromProduct);
    },

    generatePickListObject : function(list) {
        let listOfObjectForPickList = [];

        list.forEach(function(item) {
            listOfObjectForPickList.push({
                value: item,
                label: item
            });
        });

        return listOfObjectForPickList;
    },

    doCheckValid : function(component, event) {
        let min = component.get('v.searchMinPrice');
        let max = component.get('v.searchMaxPrice');

        if ((!min || !max ) && min != 0 && max != 0) return null;

        if (typeof min === 'string') min = parseFloat(min);

        if (typeof max === 'string') max = parseFloat(max);

        if (min > max) {
             component.set('v.searchValid', false);
             return null;
        }

        component.set('v.searchValid', true);
    },

    doSlideMoreCredentials : function(component, event) {
        document.getElementById('wrapper').classList.toggle('wrap-show');
        document.getElementById('chevrond').classList.toggle('wrap-rotate');
    },

    doSlideClearCredentials : function(component, event, clearAll) {
        if (clearAll) {
            component.set('v.searchText', '');
            component.set('v.searchBook', true);
            component.set('v.searchMovie', true);
        }

        component.set('v.searchGenre', '');
        component.set('v.searchType', '');
        component.set('v.searchConditions', '');
        component.set('v.searchAuthor', '');
        component.set('v.searchDate', undefined);
        component.set('v.searchMinPrice', undefined);
        component.set('v.searchMaxPrice', undefined);
    },

    doHandleSearch : function(component, event) {
        let searchText = component.get('v.searchText');
        let searchBook = component.get('v.searchBook');
        let searchMovie = component.get('v.searchMovie');
        let searchGenre = component.get('v.searchGenre');
        let searchType = component.get('v.searchType');
        let searchConditions = component.get('v.searchConditions');
        let searchAuthor = component.get('v.searchAuthor');
        let searchDate = $A.localizationService.formatDate(component.get('v.searchDate'), "yyyy-MM-dd");
        let searchMaxPrice = component.get('v.searchMaxPrice') || undefined;
        let searchMinPrice = component.get('v.searchMinPrice') || undefined;
        let action = component.get('c.searchForProducts');

        let credentials = {
            searchText : searchText,
            searchBook : searchBook,
            searchMovie : searchMovie,
            searchGenre : searchGenre,
            searchType : searchType,
            searchConditions : searchConditions,
            searchAuthor : searchAuthor,
            searchDate : searchDate,
            searchMaxPrice : searchMaxPrice,
            searchMinPrice : searchMinPrice
        }

        action.setParam('jsonCredentialsObject', JSON.stringify(credentials));

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var products = response.getReturnValue();

                console.log(products);

                sessionStorage.setItem('customSearch--recordProducts', products);

                var navEvt = $A.get('e.force:navigateToURL');

                navEvt.setParams({url: '/results'});
                navEvt.fire();
            }
        });

        $A.enqueueAction(action);
    },
})