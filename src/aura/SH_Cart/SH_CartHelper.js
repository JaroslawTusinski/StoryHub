({
    doInit : function(component, event) {
        const getCart = component.get('c.getAllProductsFromUserCart');
        if (getCart) {
            getCart.setCallback(this, function(response) {
                this.cartCallback(component, response);
            });

            $A.enqueueAction(getCart);
            this.switchSpinner(component, true);
        }
        else {
            console.error("'getCart' does not exist");
        }
    },

    doShowItems : function(component, event) {
        document.getElementById('show-cart').classList.toggle('show-cart-items');

        if (component.get('v.isCartListDisplay')) {
            component.set('v.isCartListDisplay', false);
        }
        else {
            component.set('v.isCartListDisplay', true);
        }
    },

    doAddProductToCart : function(component, event) {
        let args = event.getParam('arguments');

        if (args) {
            let productID = args.productID;
            let productType = args.productType;
            let productImgUrl = args.productImgUrl;

            this.addProduct(component, productID, productType, productImgUrl);
        }
    },

    addProduct : function(component, productID, productType, productImgUrl) {
        const addToCart = component.get('c.addProductToCart');

        if (addToCart) {
            addToCart.setParams({
                productID : productID,
                productType : productType,
                productImgUrl : productImgUrl
            });

            addToCart.setCallback(this, function(response) {
                this.cartCallback(component, response);
            });

            $A.enqueueAction(addToCart);
            this.switchSpinner(component, true);
        }
        else {
            console.error("'addToCart' does not exist");
        }
    },

    cartCallback : function(component, response) {
        let state = response.getState();

        if (state === 'SUCCESS') {
            component.set('v.products', response.getReturnValue());

            let value = 0;
            response.getReturnValue().forEach(function(prc) {
                value += (prc.UnitPrice * (prc.Quantity + 1) - prc.UnitPrice);
            });

            component.set('v.price', value);
        }
        else {
            // TODO
        }

        this.switchSpinner(component, false);
    },

    switchSpinner : function(component, status) {
        const spinnerComponent = component.find('spinner');

        if (spinnerComponent) {
            spinnerComponent.switchSpinner(status);
        }
    },

    changeNumberOfItem : function(component, event, howChange) {
        let changeNumberOfItemAction;
        const productID = event.currentTarget.dataset.id;
        const productType = event.currentTarget.dataset.type;

        if (howChange) {
            changeNumberOfItemAction = component.get('c.addCloneProduct');
        }
        else {
            changeNumberOfItemAction = component.get('c.deleteProductFromCart');
        }

        console.log(productID);
        console.log(productType);

        changeNumberOfItemAction.setParams({
            'productID': productID,
            'productType': productType
        });

        changeNumberOfItemAction.setCallback(this, function(response) {
            this.cartCallback(component, response);
        });

        $A.enqueueAction(changeNumberOfItemAction);
        this.switchSpinner(component, true);
    },
})