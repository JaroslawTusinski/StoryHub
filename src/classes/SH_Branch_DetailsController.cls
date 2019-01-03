public with sharing class SH_Branch_DetailsController {
    @AuraEnabled
    public static Account searchAccountByID(String accountID) {
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();

        queryBuilder.addSelect('Id');
        queryBuilder.addSelect('Name');
        queryBuilder.addSelect('Phone');
        queryBuilder.addSelect('BillingCountry');
        queryBuilder.addSelect('BillingState');
        queryBuilder.addSelect('BillingCity');
        queryBuilder.addSelect('BillingStreet');
        queryBuilder.addSelect('BillingPostalCode');
        queryBuilder.addSelect('ShippingCountry');
        queryBuilder.addSelect('ShippingState');
        queryBuilder.addSelect('ShippingCity');
        queryBuilder.addSelect('ShippingStreet');
        queryBuilder.addSelect('ShippingPostalCode');
        queryBuilder.addFrom('Account');
        queryBuilder.addWhere('Id = \'' + accountID + '\'');

        return Database.query(queryBuilder.getQuery());
    }

    @AuraEnabled
    public static List<Employee__c> searchEmployeesByAccountID(String accountID) {
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();

        List<Employee__c> usersByAccountID = [SELECT User__c FROM Employee__c WHERE Account__c = :accountID];

        if (!usersByAccountID.isEmpty()) {
            queryBuilder.addSelect('Id');
            queryBuilder.addSelect('Name');
            queryBuilder.addSelect('SenderEmail');
            queryBuilder.addSelect('Phone');
            queryBuilder.addSelect('MobilePhone');
            queryBuilder.addSelect('Title');
            queryBuilder.addFrom('User');
            queryBuilder.addWhere('Id = \'' + usersByAccountID[0].User__c + '\'');

            for (Integer i = 1; i < usersByAccountID.size(); i++) {
                queryBuilder.addWhere('Id = \'' + usersByAccountID[i].User__c + '\'', 'OR', '');
            }

            return Database.query(queryBuilder.getQuery());
        }

        return null;
    }
}