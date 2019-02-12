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

    doAddToCart : function(component, event) {
        let productID = (component.get('v.product')).ind;
        let productType = component.get('v.selectedProductType');
        let productPrice = component.get('v.product').salePrice || component.get('v.product').price;
        let productImgUrl = component.get('v.product').imgUrls[0];

        const cartComponent = component.find('cart');

        if (cartComponent) {
            cartComponent.addProductToCart(productID, productType, productPrice, productImgUrl);
        }
    },
})