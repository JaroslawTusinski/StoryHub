({
    doSelectProduct : function(component, event, isSelected) {
        component.set('v.isProductSelected', isSelected);

        if (isSelected) {
            const productIndex = event.currentTarget.dataset.index;

            if (productIndex) {
                let productsList = component.get('v.Products');
                let currentProduct = productsList[parseInt(productIndex)];
                let productTypes = currentProduct.product.BookType__c || currentProduct.product.MovieType__c;

                component.set('v.product', currentProduct);
                if (productTypes) component.set('v.productType', this.createProductLists(productTypes));
            }
        }
    },

    createProductLists : function(currentProductMultiSelect) {
        let basicList = currentProductMultiSelect.split(';');
        let productList = [];

        basicList.forEach(function(item) {
            productList.push({
                value: item,
                label: item
            });
        });

        return productList;
    },
})