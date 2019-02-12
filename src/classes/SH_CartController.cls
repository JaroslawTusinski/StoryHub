public with sharing class SH_CartController {
    @AuraEnabled
    public static List<OrderItem> addProductToCart(String productType, String productImgUrl, String productID) {
        if (String.isNotBlank(productType)) {
            PricebookEntry entry = [SELECT Id, Pricebook2Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :productID ORDER BY UnitPrice].get(0);
            String userID = UserInfo.getUserId();
            String cartID = getOrderID(userID, entry.Pricebook2Id);
            OrderItem item = new OrderItem();

            item.PricebookEntryId = entry.Id;
            item.Product_Type__c = productType;
            item.Photo_Url__c = productImgUrl;
            item.Product2Id = productID;
            item.UnitPrice = entry.UnitPrice;
            item.Quantity = 1;  // TODO
            item.OrderId = cartID;

            insert item;
        }

        return getAllProductsFromUserCart();
    }

    public static String getOrderID(String userID, String entryID) {
        List<Order> orders = [SELECT Id FROM Order WHERE OwnerId = :userID AND Status LIKE 'Draft'];

        if (orders.isEmpty()) {
            Pricebook2 pricebookID = [SELECT Id FROM Pricebook2 WHERE Id = :entryID].get(0);
            String contractID = getContractID(userID);
            Order order = new Order();
            order.EffectiveDate = Date.today();
            order.Pricebook2Id = pricebookID.Id;
            order.ContractId = contractID;
            order.AccountId = '0011t00000Chw5sAAB'; // TODO
            order.OwnerId = userID;
            order.Status = 'Draft';

            insert order;
            return order.Id;
        }

        return orders[0].Id;
    }

    public static String getContractID(String userID) {
        List<Contract> contracts = [SELECT Id FROM Contract WHERE ActivatedById = :userID AND Status LIKE 'Activated'];

        if (contracts.isEmpty()) {
            Contract contract = new Contract();
            contract.ContractTerm = 12;
            contract.StartDate = Date.today();
            contract.AccountId = '0011t00000Chw5sAAB'; // TODO
            contract.OwnerId = userID;
            contract.Status = 'Draft';

            insert contract;

            contract.Status = 'Activated';

            update contract;
            return contract.Id;
        }

        return contracts[0].Id;
    }

    @AuraEnabled
    public static List<OrderItem> addCloneProduct(String productID, String productType) {
        System.debug(productID);
        System.debug(productType);
        OrderItem item = ([SELECT Id, Quantity FROM OrderItem WHERE Product2Id = :productID AND Product_Type__c = :productType AND Order.Status LIKE 'Draft' AND Order.OwnerId = :UserInfo.getUserId()]).get(0);

        ++item.Quantity;

        update item;
        return getAllProductsFromUserCart();
    }

    @AuraEnabled
    public static List<OrderItem> deleteProductFromCart(String productID, String productType) {
        System.debug('productID : ' + productID);
        System.debug('productType : ' + productType);
        OrderItem item = ([SELECT Id, Quantity FROM OrderItem WHERE Product2Id = :productID AND Product_Type__c = :productType AND Order.Status LIKE 'Draft' AND Order.OwnerId = :UserInfo.getUserId()]).get(0);

        System.debug('item : ' + item);

        if (item.Quantity > 1) {
            --item.Quantity;

            update item;
        }
        else {
            delete item;
        }

        return getAllProductsFromUserCart();
    }

    @AuraEnabled
    public static List<OrderItem> getAllProductsFromUserCart() {
        String userID = UserInfo.getUserId();

        return [SELECT Product2Id, UnitPrice, Quantity, Product_Type__c, Photo_Url__c, Product2.Name FROM OrderItem WHERE Order.OwnerId = :userID AND Order.Status LIKE 'Draft' ORDER BY Product2.Name, Product_Type__c, UnitPrice];
    }
}