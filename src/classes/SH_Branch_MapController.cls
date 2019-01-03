public with sharing class SH_Branch_MapController {
    @AuraEnabled
    public static List<Account> searchAccountByID(List<String> accountsIDs) {
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();

        queryBuilder.addSelect('Name');
        queryBuilder.addSelect('BillingCountry');
        queryBuilder.addSelect('BillingCity');
        queryBuilder.addSelect('BillingStreet');
        queryBuilder.addSelect('ShippingCountry');
        queryBuilder.addSelect('ShippingCity');
        queryBuilder.addSelect('ShippingStreet');
        queryBuilder.addFrom('Account');
        queryBuilder.addWhere('RecordType.DeveloperName = \'Shop\'', '', 'AND (');

        for (Integer i = 0; i < accountsIDs.size() - 1; i++) {
            queryBuilder.addWhere('Id = \'' + accountsIDs[i] + '\'', '', 'OR');
        }

        queryBuilder.addWhere('Id = \'' + accountsIDs[accountsIDs.size() - 1] + '\'', '', ')');

        return Database.query(queryBuilder.getQuery());
    }
}