public with sharing class SH_CommentingController {
    @AuraEnabled
    public static List<MovieComment__c> saveComment(String userComment, String productID) {
        MovieComment__c comment = new MovieComment__c();

        if (String.isNotBlank(userComment)) {
            comment.Comment__c = userComment;
            comment.MovieId__c = productID;
            comment.CurrentDate__c = system.now();
            comment.UserName__c = UserInfo.getName();

            insert comment;
        }

        return [SELECT Comment__c, CurrentDate__c, UserName__c FROM MovieComment__c WHERE MovieId__c LIKE :productID ORDER BY CurrentDate__c];
    }

    @AuraEnabled
    public static List<MovieComment__c> getComment(String productID) {
        return [SELECT Comment__c, CurrentDate__c, UserName__c FROM MovieComment__c WHERE MovieId__c LIKE :productID ORDER BY CurrentDate__c];
    }
}