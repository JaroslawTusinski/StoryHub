public with sharing class SH_Branch_MapController {
    @AuraEnabled
    public static List<Account> searchAccountByID(List<String> accountsIDs) {
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();
        List<String> fieldList = new List<String>{'Name', 'BillingCountry', 'BillingCity', 'BillingStreet', 'ShippingCountry', 'ShippingCity', 'ShippingStreet'};

        queryBuilder.addSelect(fieldList)
                    .addFrom('Account')
                    .addWhere('RecordType.DeveloperName = \'Shop\'')
                        .startANDBlock();

        for (Integer i = 0; i < accountsIDs.size() - 1; i++) {
            queryBuilder.addWhere('Id = \'' + accountsIDs[i] + '\'').addOR();
        }

        queryBuilder.addWhere('Id = \'' + accountsIDs[accountsIDs.size() - 1] + '\'').closeBlock();

        return Database.query(queryBuilder.buildQuery());
    }
}