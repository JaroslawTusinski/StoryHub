public with sharing class SH_Branch_ResultsController {
    @AuraEnabled
    public static List<Account> searchAccountByCredentialsObject(String credentialsObjectJSON) {
        CredentialsObject credentials = (CredentialsObject) System.JSON.deserialize(credentialsObjectJSON, CredentialsObject.class);
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();
        List<String> fieldList = new List<String>{'Id', 'Name', 'Type', 'Phone', 'BillingCountry', 'BillingCity', 'ShippingCountry', 'ShippingCity'};

        queryBuilder.addSelect(fieldList)
                    .addFrom('Account')
                    .addWhere('RecordType.DeveloperName = \'Shop\'').startANDBlock()
                        .addWhere('BillingCountry LIKE \'' + credentials.country + '%\'').addOR()
                        .addWhere('ShippingCountry LIKE \'' + credentials.country + '%\'')
                    .closeBlock().startANDBlock()
                        .addWhere('BillingCity LIKE \'' + credentials.city + '%\'').addOR()
                        .addWhere('ShippingCity LIKE \'' + credentials.city + '%\'')
                    .closeBlock()
                    .addSort('Name').addSort('ShippingCountry').addSort('BillingCountry').addSort('ShippingCity').addSort('BillingCity').addSort('ShippingStreet').addSort('BillingStreet');

        return Database.query(queryBuilder.buildQuery());
    }

    private class CredentialsObject {
        public String country;
        public String city;
    }
}