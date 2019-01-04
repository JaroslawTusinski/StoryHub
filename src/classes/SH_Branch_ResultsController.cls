public with sharing class SH_Branch_ResultsController {
    @AuraEnabled
    public static List<Account> searchAccountByCredentialsObject(String credentialsObjectJSON) {
        CredentialsObject credentials = (CredentialsObject) System.JSON.deserialize(credentialsObjectJSON, CredentialsObject.class);
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();
        List<String> fieldList = new List<String>{'Id', 'Name', 'Type', 'Phone', 'BillingCountry', 'BillingCity', 'ShippingCountry', 'ShippingCity'};

        queryBuilder.addSelect(fieldList);
        queryBuilder.addFrom('Account');
        queryBuilder.addWhere('RecordType.DeveloperName = \'Shop\'');
        queryBuilder.startANDBlock();
        queryBuilder.addWhere('BillingCountry LIKE \'' + credentials.country + '%\'');
        queryBuilder.addOR();
        queryBuilder.addWhere('ShippingCountry LIKE \'' + credentials.country + '%\'');
        queryBuilder.closeBlock();
        queryBuilder.startANDBlock();
        queryBuilder.addWhere('BillingCity LIKE \'' + credentials.city + '%\'');
        queryBuilder.addOR();
        queryBuilder.addWhere('ShippingCity LIKE \'' + credentials.city + '%\'');
        queryBuilder.closeBlock();
        queryBuilder.addSort('Name');
        queryBuilder.addSort('ShippingCountry');
        queryBuilder.addSort('BillingCountry');
        queryBuilder.addSort('ShippingCity');
        queryBuilder.addSort('BillingCity');
        queryBuilder.addSort('ShippingStreet');
        queryBuilder.addSort('BillingStreet');

        return Database.query(queryBuilder.getQuery());
    }

    private class CredentialsObject {
        public String country;
        public String city;
    }
}