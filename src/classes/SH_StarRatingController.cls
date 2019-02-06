public with sharing class SH_StarRatingController {
    @AuraEnabled
    public static List<Double> saveRate(Integer rate, String productID) {
        String userID = UserInfo.getUserId();
        MovieOpinion__c opinion;

        try {
            opinion = [SELECT Id, Rating__c FROM MovieOpinion__c WHERE MovieID__c LIKE :productID AND UserID__c LIKE :userID];

            opinion.Rating__c = Integer.valueOf(rate);

            update opinion;
        }
        catch (Exception e) {
            try {
                opinion = new MovieOpinion__c();

                opinion.MovieID__c = productID;
                opinion.UserID__c = userID;
                opinion.Rating__c = Integer.valueOf(rate);

                insert opinion;
            }
            catch (Exception ex) {
                throw ex;
            }
        }

        return getAverageRating(productID);
    }

    @AuraEnabled
    public static List<Double> getAverageRating(String productID) {
        String userID = UserInfo.getUserId();
        Double userRate;
        Double averageRating = Double.valueOf([SELECT AVG(Rating__c) averageRating FROM MovieOpinion__c WHERE MovieID__c LIKE :productID].get(0).get('averageRating'));
        Double usersNumber = Double.valueOf([SELECT COUNT(Rating__c) usersNumber FROM MovieOpinion__c WHERE MovieID__c LIKE :productID].get(0).get('usersNumber'));

        try {
            userRate = Double.valueOf([SELECT Rating__c FROM MovieOpinion__c WHERE MovieID__c LIKE :productID AND UserID__c LIKE :userID].get(0).Rating__c);
        }
        catch (Exception e) {
            userRate = 0;
        }

        List<Double> rating = new List<Double>{
                userRate,
                usersNumber,
                averageRating
        };

        return rating;
    }
}