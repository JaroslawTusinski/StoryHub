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

    public static Boolean getUserPermissionSet(){
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

        public void addSelect(String field){
            qSelect.add(field);
        }
        public void addSelect(List<String> fields){
            qSelect.addAll(fields);
        }

        public void addFrom(String fromObject){
            qFrom = fromObject;
        }

        public void addAND(){
            addWhere('AND ');
        }
        public void startANDBlock(){
            addWhere('AND ( ');
        }

        public void addOR(){
            addWhere('OR ');
        }
        public void startORBlock(){
            addWhere('OR ( ');
        }

        public void startINBlock(){
            addWhere('IN ( ');
        }

        public void closeBlock(){
            addWhere(') ');
        }

        public void addWhere(String whereField){
            qWhere += (whereField + ' ');
        }
        public void addWhereAND(List<String> whereFields){
            for (String field : whereFields) {
                addAND();
                addWhere(field);
            }
        }
        public void addWhereOR(List<String> whereFields){
            for (String field : whereFields) {
                addOR();
                addWhere(field);
            }
        }

        public void addSort(String field){
            qSort.add(field);
        }
        public void addSort(List<String> fields){
            qSort.addAll(fields);
        }
        public void addSort(String field, String sortOrder){
            qSort.add(field + ' ' + sortOrder);
        }
        public void addSort(List<String> fields, List<String> sortOrders){
            for (Integer i = 0; i < fields.size(); i++) {
                addSort(fields[i], sortOrders[i]);
            }
        }

        public String getQuery() {
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