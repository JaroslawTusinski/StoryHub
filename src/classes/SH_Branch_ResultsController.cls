public with sharing class SH_Branch_ResultsController {
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccountByCredentialsObject(String credentialsObjectJSON) {
        return searchAccountByCredentialsObjectWithoutStorable(credentialsObjectJSON);
    }

    @AuraEnabled
    public static List<Account> searchAccountByCredentialsObjectWithoutStorable(String credentialsObjectJSON) {
        CredentialsObject credentials = (CredentialsObject) System.JSON.deserialize(credentialsObjectJSON, CredentialsObject.class);
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();

        queryBuilder.addSelect('Id');
        queryBuilder.addSelect('Name');
        queryBuilder.addSelect('Type');
        queryBuilder.addSelect('Phone');
        queryBuilder.addSelect('BillingCountry');
        queryBuilder.addSelect('BillingCity');
        queryBuilder.addSelect('ShippingCountry');
        queryBuilder.addSelect('ShippingCity');
        queryBuilder.addFrom('Account');
        queryBuilder.addWhere('RecordType.DeveloperName = \'Shop\'', '', 'AND');
        queryBuilder.addWhere('(BillingCountry LIKE \'' + credentials.country + '%\'', '', 'OR');
        queryBuilder.addWhere('ShippingCountry LIKE \'' + credentials.country + '%\')', '', 'AND');
        queryBuilder.addWhere('(BillingCity LIKE \'' + credentials.city + '%\'', '', 'OR');
        queryBuilder.addWhere('ShippingCity LIKE \'' + credentials.city + '%\')');
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