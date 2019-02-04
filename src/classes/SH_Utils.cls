public with sharing class SH_Utils {
    public static List<String> accountFieldList = new List<String>{
            'Name',
            'BillingCountry',
            'BillingCity',
            'BillingStreet',
            'ShippingCountry',
            'ShippingCity',
            'ShippingStreet'
    };

    public static List<String> employeeFieldList = new List<String>{
            'FirstName',
            'LastName',
            'SenderEmail',
            'Phone',
            'MobilePhone',
            'Title'
    };

    public static Boolean getUserPermissionSet_Permission_to_delete_accounts(){
        List<PermissionSetAssignment> permsetForGivenUser = [
                SELECT Id
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
                    AND PermissionSet.Name = 'Permission_to_delete_accounts'];

        return permsetForGivenUser.size() != 0;
    }

    public static Map<String, String> getObjectLabelMap(String type) {
        Map<String, String> mapFieldsApiNameLabel = new Map<string, string>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        for (String fieldName : fieldMap.keySet()) {
            fieldMap.get(fieldName).getDescribe().getLabel();
            mapFieldsApiNameLabel.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
        }

        return mapFieldsApiNameLabel;
    }

    public static List<String> getAllOptionsFromObjectPickList(SObject objObject, String field) {
        List <String> allOptions = new list<String>();
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list <Schema.PicklistEntry> values = fieldMap.get(field).getDescribe().getPickListValues();

        for (Schema.PicklistEntry val: values) {
            allOptions.add(val.getValue());
        }

        return allOptions;
    }

    public class QueryBuilder {
        private List<String> qSelect;
        private List<String> qSort;
        private String qFrom;
        private String qWhere;

        public QueryBuilder() {
            qSelect = new List<String>();
            qSort = new List<String>();
            qFrom = '';
            qWhere = '';
        }

        public QueryBuilder addSelect(String field){
            qSelect.add(field);

            return this;
        }
        public QueryBuilder addSelect(List<String> fields){
            qSelect.addAll(fields);

            return this;
        }

        public QueryBuilder addFrom(String fromObject){
            qFrom = fromObject;

            return this;
        }

        public QueryBuilder addAND(){
            addWhere('AND ');

            return this;
        }
        public QueryBuilder startANDBlock(){
            addWhere('AND ( ');

            return this;
        }

        public QueryBuilder addOR(){
            addWhere('OR ');

            return this;
        }
        public QueryBuilder startORBlock(){
            addWhere('OR ( ');

            return this;
        }

        public QueryBuilder startINBlock(){
            addWhere('IN ( ');

            return this;
        }

        public QueryBuilder closeBlock(){
            addWhere(') ');

            return this;
        }

        public QueryBuilder addWhere(String whereField){
            qWhere += (whereField + ' ');

            return this;
        }
        public QueryBuilder addWhereAND(List<String> whereFields){
            for (String field : whereFields) {
                addAND();
                addWhere(field);
            }

            return this;
        }
        public QueryBuilder addWhereOR(List<String> whereFields){
            for (String field : whereFields) {
                addOR();
                addWhere(field);
            }

            return this;
        }

        public QueryBuilder addSort(String field){
            qSort.add(field);

            return this;
        }
        public QueryBuilder addSort(List<String> fields){
            qSort.addAll(fields);

            return this;
        }
        public QueryBuilder addSort(String field, String sortOrder){
            qSort.add(field + ' ' + sortOrder);

            return this;
        }

        public String buildQuery() {
            String query;

            query = 'SELECT' + constructQuery(qSelect);
            query += ' FROM ' + qFrom;
            if (String.isNotBlank(qWhere)) {
                query += ' WHERE ' + qWhere;
            }
            if (!qSort.isEmpty()) {
                query += 'ORDER BY ' + constructQuery(qSort);
            }

            return query;
        }

        private String constructQuery(List<String> fields) {
            Boolean isNotFirstElement = false;
            String query = '';

            for (String field : fields) {
                if (isNotFirstElement) {
                    query += ',';
                }

                query += (' ' + field);
                isNotFirstElement = true;
            }

            return query;
        }
    }

    public class ModalObjectTemplate {
        public String value;
        public String label;
        public String key;
        public Boolean require;

        public ModalObjectTemplate() {
            value = '';
            label = '';
            key = '';
            require = false;
        }

        public ModalObjectTemplate(String value, String label, String key, Boolean require) {
            this.value = value;
            this.label = label;
            this.key = key;
            this.require = require;
        }
    }
}