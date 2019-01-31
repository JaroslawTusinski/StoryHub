public with sharing class SH_Branch_DetailsController {
    @AuraEnabled
    public static Account getAccountByID(String accountID) {
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();
        List<String> fieldList = new List<String>{'Id', 'Name', 'Phone', 'BillingCountry', 'BillingState', 'BillingCity', 'BillingStreet', 'BillingPostalCode', 'ShippingCountry', 'ShippingState', 'ShippingCity', 'ShippingStreet', 'ShippingPostalCode'};

        queryBuilder.addSelect(fieldList)
                    .addFrom('Account')
                    .addWhere('Id = \'' + accountID + '\'');

        return Database.query(queryBuilder.buildQuery());
    }

    @AuraEnabled
    public static List<Employee__c> searchEmployeesByAccountID(String accountID) {
        List<Employee__c> usersByAccountID = [SELECT User__c FROM Employee__c WHERE Account__c = :accountID];

        if (!usersByAccountID.isEmpty()) {
            SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();
            List<String> fieldList = new List<String>{'Id', 'Name', 'SenderEmail', 'Phone', 'MobilePhone', 'Title'};

            queryBuilder.addSelect(fieldList)
                        .addFrom('User')
                        .addWhere('Id = \'' + usersByAccountID[0].User__c + '\'');

            for (Integer i = 1; i < usersByAccountID.size(); i++) {
                queryBuilder.addOR().addWhere('Id = \'' + usersByAccountID[i].User__c + '\'');
            }

            return Database.query(queryBuilder.buildQuery());
        }

        return null;
    }

    @AuraEnabled
    public static Boolean checkUserPermissionToDelete() {
        return SH_Utils.getUserPermissionSet_Permission_to_delete_accounts();
    }
}