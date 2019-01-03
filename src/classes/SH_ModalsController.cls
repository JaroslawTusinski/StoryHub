public with sharing class SH_ModalsController {
    @AuraEnabled(cacheable=true)
    public static String searchObjectByID(String objectID, String objectName) {
        switch on objectName {
            when 'Account' {
                return searchAccountDetailsByID(SH_Utils.accountFieldList, objectID);
            }
            when 'Employee__c' {
                return searchEmployeeDetailsByID(SH_Utils.employeeFieldList, objectID);
            }
        }

        return null;
    }

    private static String searchAccountDetailsByID(List<String> fieldList, String accountID) {
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();

        for(String field : fieldList) {
            queryBuilder.addSelect(field);
        }
        queryBuilder.addFrom('Account');
        queryBuilder.addWhere('Id = \'' + accountID + '\'');

        return objectListCreator(fieldList, Database.query(queryBuilder.getQuery()).get(0));
    }

    private static String searchEmployeeDetailsByID(List<String> fieldList, String userID) {
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();

        for(String field : fieldList) {
            queryBuilder.addSelect(field);
        }
        queryBuilder.addFrom('User');
        queryBuilder.addWhere('Id = \'' + userID + '\'');

        return objectListCreator(fieldList, Database.query(queryBuilder.getQuery()).get(0));
    }

    private static String objectListCreator(List<String> fieldList, SObject obj) {
        List<SH_Utils.ModalObjectTemplate> listOfObjects = new List<SH_Utils.ModalObjectTemplate>();

        for (String key : fieldList) {
            Boolean require = false;
            if (key.equals('Id') || key.equals('Name')) {
                require = true;
            }

            String value = (String) obj.get(key);
            if (String.isBlank(value)) {
                value = '';
            }

            listOfObjects.add(new SH_Utils.ModalObjectTemplate(value, key, require));
        }

        return JSON.serialize(listOfObjects);
    }

    @AuraEnabled
    public static Boolean saveObject(String objectJSON, String objectName, String objectID) {
        switch on objectName {
            when 'Account' {
                return upsertAccount((List<SH_Utils.ModalObjectTemplate>) System.JSON.deserialize(objectJSON, List<SH_Utils.ModalObjectTemplate>.class), objectID);
            }
            when 'Employee__c' {
                return upsertEmployee((List<SH_Utils.ModalObjectTemplate>) System.JSON.deserialize(objectJSON, List<SH_Utils.ModalObjectTemplate>.class), objectID);
            }
        }

        return false;
    }

    private static Boolean upsertAccount(List<SH_Utils.ModalObjectTemplate> accountObjects, String accountID) {
        Account a = new Account();

        a.put('Id', accountID);
        for (SH_Utils.ModalObjectTemplate accountField : accountObjects) {
            a.put(accountField.key, accountField.value);
        }

        try {
            upsert a;
            return true;
        }
        catch (Exception e) {
            throw e;
        }
    }

    private static Boolean upsertEmployee(List<SH_Utils.ModalObjectTemplate> employeeObjects, String employeeID) {
        User employee = new User();

        employee.put('Id', employeeID);
        for (SH_Utils.ModalObjectTemplate employeeField : employeeObjects) {
            employee.put(employeeField.key, employeeField.value);
        }

        try {
            update employee;
            return true;
        }
        catch (Exception e) {
            throw e;
        }
    }

    @AuraEnabled
    public static Boolean deleteObjectByID(String objectName, String objectID, String secondObjectID) {
        switch on objectName {
            when 'Account' {
                return deleteAccount(objectID);
            }
            when 'Employee__c' {
                return deleteEmployee(objectID, secondObjectID);
            }
        }

        return false;
    }

    private static Boolean deleteAccount(String accountID) {
        Account a = new Account(Id = accountID);

        try {
            delete a;
            return true;
        }
        catch (Exception e) {
            throw e;
        }
    }

    private static Boolean deleteEmployee(String objectID, String secondObjectID) {
        Employee__c employee;

        try {
            employee = [SELECT Id FROM Employee__c WHERE Account__c = :objectID AND User__c = :secondObjectID];

            delete employee;
            return true;
        }
        catch (Exception ex) {
            try {
                employee = [SELECT Id FROM Employee__c WHERE Account__c = :secondObjectID AND User__c = :objectID];

                delete employee;
                return true;
            }
            catch (Exception e) {
                throw e;
            }
        }
    }
}