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

    public class QueryBuilder {
        private List<String> qSelect;
        private List<String> qFrom;
        private List<String> qWhere;
        private List<String> qSort;

        public QueryBuilder() {
            qSelect = new List<String>();
            qFrom = new List<String>();
            qWhere = new List<String>();
            qSort = new List<String>();
        }

        public void addSelect(String field){
            qSelect.add(field);
        }
        public void addSelect(String field, String fieldFrom){
            qSelect.add(field);
        }

        public void addFrom(String fromObject){
            qFrom.add(fromObject);
        }
        public void addFrom(String fromObject, String alias){
            qFrom.add(fromObject + ' ' + alias);
        }

        public void addWhere(String whereField){
            qWhere.add(whereField);
        }
        public void addWhere(String whereField, String logicOperatorToPreviousField, String logicOperatorToNextField){
            String field = whereField;

            if (String.isNotBlank(logicOperatorToPreviousField)) {
                field = logicOperatorToPreviousField + ' ' + field;
            }
            if (String.isNotBlank(logicOperatorToNextField)) {
                field += (' ' + logicOperatorToNextField);
            }

            qWhere.add(field);
        }

        public void addSort(String field){
            qSort.add(field);
        }
        public void addSort(String field, String sortOrder){
            qSort.add(field + ' ' + sortOrder);
        }

        public String getQuery() {
            String query;

            query = 'SELECT' + constructQuery(qSelect, true);
            query += ' FROM' + constructQuery(qFrom, true);
            if (!qWhere.isEmpty()) {
                query += ' WHERE' + constructQuery(qWhere, false);
            }
            if (!qSort.isEmpty()) {
                query += ' ORDER BY' + constructQuery(qSort, true);
            }

            return query;
        }

        private String constructQuery(List<String> fields, Boolean isWhere) {
            Boolean isNotFirstElement = false;
            String query = '';

            for (String field : fields) {
                if (isNotFirstElement && isWhere) {
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
        public String key;
        public Boolean require;

        public ModalObjectTemplate() {
            value = '';
            key = '';
            require = false;
        }

        public ModalObjectTemplate(String value, String key, Boolean require) {
            this.value = value;
            this.key = key;
            this.require = require;
        }
    }
}