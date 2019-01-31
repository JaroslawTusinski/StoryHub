public with sharing class SH_ModalsController {
    @AuraEnabled(cacheable=true)
    public static String searchObjectByID(String objectID, String objectName) {
        List<String> listOfFields;

        switch on objectName {
            when 'Account' {
                listOfFields = SH_Utils.accountFieldList;
            }
            when 'User' {
                listOfFields = SH_Utils.employeeFieldList;
            }
            when else {
                listOfFields = new List<String>();
            }
        }

        return searchObjectDetailsByID(listOfFields, objectID, objectName);
    }

    private static String searchObjectDetailsByID(List<String> fieldList, String objectID, String objectName) {
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();

        queryBuilder.addSelect(fieldList)
                    .addFrom(objectName)
                    .addWhere('Id = \'' + objectID + '\'');

        return objectListCreator(fieldList, Database.query(queryBuilder.buildQuery()).get(0), objectName);
    }

    private static String objectListCreator(List<String> fieldList, SObject obj, String objectName) {
        List<SH_Utils.ModalObjectTemplate> listOfObjects = new List<SH_Utils.ModalObjectTemplate>();
        Map<String, String> mapOfLabels = SH_Utils.getObjectLabelMap(objectName);

        for (String key : fieldList) {
            Boolean require = false;
            if (key.equalsIgnoreCase('Id') || key.equalsIgnoreCase('Name')) {
                require = true;
            }

            String value = (String) obj.get(key);
            if (String.isBlank(value)) {
                value = '';
            }

            listOfObjects.add(new SH_Utils.ModalObjectTemplate(value, mapOfLabels.get(key.toLowerCase()), key, require));
        }

        return JSON.serialize(listOfObjects);
    }

    @AuraEnabled
    public static Boolean saveObject(String objectJSON, String objectName, String objectID) {
        List<SH_Utils.ModalObjectTemplate> modObjTem = (List<SH_Utils.ModalObjectTemplate>) System.JSON.deserialize(objectJSON, List<SH_Utils.ModalObjectTemplate>.class);

        return updateObject(modObjTem, objectID, objectName);
    }

    private static Boolean updateObject(List<SH_Utils.ModalObjectTemplate> modObjTem, String objectID, String objectName) {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        if (objType != null) {
            sObject obj = objType.newSObject();

            obj.put('Id', objectID);
            for (SH_Utils.ModalObjectTemplate field : modObjTem) {
                obj.put(field.key, field.value);
            }

            try {
                update obj;
                return true;
            } catch (Exception e) {
                throw e;
            }
        }

        return false;
    }

    @AuraEnabled
    public static Boolean deleteObjectByID(String objectName, String objectID, String secondObjectID) {
        if (String.isNotBlank(objectID) && String.isNotBlank(secondObjectID)) {
            return deleteJunctionObject(objectID, secondObjectID, objectName);
        }

        return deleteObject(objectID, objectName);
    }

    private static Boolean deleteObject(String objectID, String objectName) {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        if (objType != null) {
            sObject obj = objType.newSObject();
            obj.put('Id', objectID);

            try {
                delete obj;
                return true;
            }
            catch (Exception e) {
                throw e;
            }
        }

        return false;
    }

    private static Boolean deleteJunctionObject(String objectID, String secondObjectID, String objectName) { // TODO - needs refactoring
        sObject obj;
        String firstObj;
        String secondObj;

        switch on objectName {
            when 'Employee__c' {
                firstObj = 'Account__c';
                secondObj = 'User__c';
            }
        }

        try {
            obj = Database.query('SELECT Id FROM ' + objectName + ' WHERE ' + firstObj + ' = \'' + objectID + '\' AND ' + secondObj + ' = \'' + secondObjectID + '\'');

            delete obj;
            return true;
        }
        catch (Exception ex) {
            try {
                obj = Database.query('SELECT Id FROM ' + objectName + ' WHERE ' + secondObj + ' = \'' + objectID + '\' AND ' + firstObj + ' = \'' + secondObjectID + '\'');

                delete obj;
                return true;
            }
            catch (Exception e) {
                throw e;
            }
        }
    }

    @AuraEnabled
    public static List<User> searchEmployees(String accountID) {
        System.debug('accountID : ' + accountID);
        List<Employee__c> usersByAccountID = [SELECT User__c FROM Employee__c WHERE Account__c = :accountID];
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();
        List<String> fieldList = new List<String>{
                'Id', 'Name', 'Title'
        };

        queryBuilder.addSelect(fieldList)
                    .addFrom('User')
                    .addWhere('Profile.UserLicense.Name like \'%Salesforce%\'');

        if (!usersByAccountID.isEmpty()) {
            for (Integer i = 0; i < usersByAccountID.size(); i++) {
                queryBuilder.addAND().addWhere('Id != \'' + usersByAccountID[i].User__c + '\'');
            }
        }

        queryBuilder.addSort('Name').addSort('Title');

        System.debug(queryBuilder.buildQuery());

        return Database.query(queryBuilder.buildQuery());
    }

    @AuraEnabled
    public static Boolean addRelationEmployeeAndAccount(String accountID, String userID) {
        Employee__c e = new Employee__c();

        e.User__c = userID;
        e.Account__c = accountID;

        try {
            insert e;
            return true;
        }
        catch (Exception ex) {
            throw ex;
        }
    }
}