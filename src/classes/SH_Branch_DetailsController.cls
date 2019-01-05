public with sharing class SH_Branch_DetailsController {
    @AuraEnabled
    public static Account searchAccountByID(String accountID) {
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();
        List<String> fieldList = new List<String>{'Id', 'Name', 'Phone', 'BillingCountry', 'BillingState', 'BillingCity', 'BillingStreet', 'BillingPostalCode', 'ShippingCountry', 'ShippingState', 'ShippingCity', 'ShippingStreet', 'ShippingPostalCode'};

        queryBuilder.addSelect(fieldList);
        queryBuilder.addFrom('Account');
        queryBuilder.addWhere('Id = \'' + accountID + '\'');

        return Database.query(queryBuilder.getQuery());
    }

    @AuraEnabled
    public static List<Employee__c> searchEmployeesByAccountID(String accountID) {
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();
        List<Employee__c> usersByAccountID = [SELECT User__c FROM Employee__c WHERE Account__c = :accountID];

        if (!usersByAccountID.isEmpty()) {
            List<String> fieldList = new List<String>{'Id', 'Name', 'SenderEmail', 'Phone', 'MobilePhone', 'Title'};

            queryBuilder.addSelect(fieldList);
            queryBuilder.addFrom('User');
            queryBuilder.addWhere('Id = \'' + usersByAccountID[0].User__c + '\'');

            for (Integer i = 1; i < usersByAccountID.size(); i++) {
                queryBuilder.addOR();
                queryBuilder.addWhere('Id = \'' + usersByAccountID[i].User__c + '\'');
            }

            return Database.query(queryBuilder.getQuery());
        }

        return null;
    }

    @AuraEnabled
    public static Boolean checkUserPermissionSet() {
        return SH_Utils.getUserPermissionSet();
    }
}