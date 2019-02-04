public with sharing class SH_ProductSearchController {
    @AuraEnabled
    public static String searchForProducts(String jsonCredentialsObject) {
        List<String> ids = new List<String>();
        List<List<String>> urls = new List<List<String>>();
        List<Product2> results = prepareProductList(jsonCredentialsObject);
        List<Products> products = new List<Products>();
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();
        SH_Utils.QueryBuilder queryBuilderForImg = new SH_Utils.QueryBuilder();

        for (Product2 product : results) {
            ids.add(product.Id);
        }

        queryBuilder.addSelect('UnitPrice')
                    .addFrom('PricebookEntry')
                    .addWhere('Product2Id')
                    .startINBlock();

        for (String ind : ids) {
            List<String> url = new List<String>();
            List<ContentDocumentLink> imgs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :ind];

            if (!imgs.isEmpty()) {
                for(ContentDocumentLink img : imgs){
                    List<ContentDistribution> publicUrl = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId = :(img.ContentDocumentId)];

                    if (!publicUrl.isEmpty()) {
                        url.add(publicUrl.get(0).ContentDownloadUrl);
                    }
                }
            }

            queryBuilder.addWhere('\'' + ind + '\',');
            urls.add(url);
        }

        queryBuilder.addWhere('\'' + ids[0] + '\'')
                    .closeBlock();

        List<PricebookEntry> prices = Database.query(queryBuilder.buildQuery());

        for (Integer i = 0; i < ids.size(); i++) {
            products.add(new Products(ids[i], prices[i].UnitPrice, urls[i]));
        }

        return JSON.serialize(products);
    }

    public static List<Product2> prepareProductList(String jsonCredentialsObject) {
        CredentialsObject credentialsObject = (CredentialsObject) System.JSON.deserialize(jsonCredentialsObject, CredentialsObject.class);
        SH_Utils.QueryBuilder query = new SH_Utils.QueryBuilder();

        query.addSelect('Id')
                .addFrom('Product2')
                .addWhere('Name LIKE \'%' + credentialsObject.searchText + '%\'').addAND()
                .addWhere('Family LIKE \'%' + credentialsObject.searchConditions + '%\'').addAND()
                .addWhere('Author__c LIKE \'%' + credentialsObject.searchAuthor + '%\'');

        if (credentialsObject.searchBook && credentialsObject.searchMovie) {
            query.startANDBlock()
                    .addWhere('RecordType.Name LIKE \'Book\'').addOR()
                    .addWhere('RecordType.Name LIKE \'Movie\'').closeBlock();
        }
        else {
            String productType = 'Book';
            if (credentialsObject.searchMovie) productType = 'Movie';

            query.addAND().addWhere('RecordType.Name LIKE \'' + productType + '\'');

            if (String.isNotBlank(credentialsObject.searchGenre)) {
                query.addAND().addWhere(productType + 'Genre__c INCLUDES (\'' + credentialsObject.searchGenre + '\')');
            }
            if (String.isNotBlank(credentialsObject.searchType)) {
                query.addAND().addWhere(productType + 'Type__c INCLUDES (\'' + credentialsObject.searchType + '\')');
            }
        }

        if (credentialsObject.searchDate != null && credentialsObject.searchDate != 'Invalid Date') {
            query.addAND().addWhere('ReleaseDate__c = ' + credentialsObject.searchDate);
        }

        if (credentialsObject.searchMinPrice >= 0 || credentialsObject.searchMaxPrice >= 0) {
            query.addAND()
                    .addWhere('Id')
                    .startINBlock()
                        .addWhere('SELECT Product2Id FROM PricebookEntry WHERE');

            if (credentialsObject.searchMinPrice >= 0) {
                query.addWhere('UnitPrice >= ' + credentialsObject.searchMinPrice);
            }
            if (credentialsObject.searchMaxPrice >= 0) {
                if (credentialsObject.searchMinPrice >= 0) {
                    query.addAND();
                }
                query.addWhere('UnitPrice <= ' + credentialsObject.searchMaxPrice);
            }

            query.closeBlock();
        }
        return Database.query(query.buildQuery());
    }

    @AuraEnabled
    public static String getAllPickListsValuesFromProduct() {
        Product2 product = new Product2();
        AllPickListsValueObject pickListsValues = new AllPickListsValueObject(
                SH_Utils.getAllOptionsFromObjectPickList(product, 'BookGenre__c'),
                SH_Utils.getAllOptionsFromObjectPickList(product, 'MovieGenre__c'),
                SH_Utils.getAllOptionsFromObjectPickList(product, 'BookType__c'),
                SH_Utils.getAllOptionsFromObjectPickList(product, 'MovieType__c'),
                SH_Utils.getAllOptionsFromObjectPickList(product, 'Family')
        );

        return JSON.serialize(pickListsValues);
    }

    public class Products {
        public String ind;
        public Decimal price;
        public List<String> imgUrls;

        public Products(String ind, Decimal price, List<String> imgUrls){
            this.ind = ind;
            this.price = price;
            this.imgUrls = imgUrls;
        }
    }

    public class AllPickListsValueObject {
        public List<String> allBookGenre;
        public List<String> allMovieGenre;
        public List<String> allBookType;
        public List<String> allMovieType;
        public List<String> allConditions;

        public AllPickListsValueObject(List<String> allBookGenre, List<String> allMovieGenre, List<String> allBookType, List<String> allMovieType, List<String> allConditions){
            this.allBookGenre = allBookGenre;
            this.allMovieGenre = allMovieGenre;
            this.allBookType = allBookType;
            this.allMovieType = allMovieType;
            this.allConditions = allConditions;
        }
    }

    public class CredentialsObject {
        public String searchText;
        public Boolean searchBook;
        public Boolean searchMovie;
        public String searchGenre;
        public String searchType;
        public String searchConditions;
        public String searchAuthor;
        public String searchDate;
        public Decimal searchMaxPrice;
        public Decimal searchMinPrice;
    }
}