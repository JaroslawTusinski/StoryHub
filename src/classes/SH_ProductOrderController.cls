public with sharing class SH_ProductOrderController {
    @AuraEnabled
    public static void activeOrder() {
        Order productOrder = [SELECT Id, Status FROM Order WHERE OwnerId = :UserInfo.getUserId()];

        productOrder.Status = 'New';

        update productOrder;
    }
}