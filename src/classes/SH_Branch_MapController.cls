public with sharing class SH_Branch_MapController {
    @AuraEnabled
    public static List<Account> searchAccountByID(List<String> accountsIDs) {
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();
        List<String> fieldList = new List<String>{'Name', 'BillingCountry', 'BillingCity', 'BillingStreet', 'ShippingCountry', 'ShippingCity', 'ShippingStreet'};

        queryBuilder.addSelect(fieldList);
        queryBuilder.addFrom('Account');
        queryBuilder.addWhere('RecordType.DeveloperName = \'Shop\'');
        queryBuilder.startANDBlock();

        for (Integer i = 0; i < accountsIDs.size() - 1; i++) {
            queryBuilder.addWhere('Id = \'' + accountsIDs[i] + '\'');
            queryBuilder.addOR();
        }

        queryBuilder.addWhere('Id = \'' + accountsIDs[accountsIDs.size() - 1] + '\'');
        queryBuilder.closeBlock();

        return Database.query(queryBuilder.getQuery());
    }
}