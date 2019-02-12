public without sharing class SH_ProductSearchController {
    @AuraEnabled
    public static String searchForProducts(String jsonCredentialsObject) {
        List<String> ids = new List<String>();
        List<Decimal> rates = new List<Decimal>();
        List<List<String>> urls = new List<List<String>>();
        List<Product2> results = prepareProductList(jsonCredentialsObject);
        List<ContentDocumentLink> documentLinks;
        List<String> linksIDs;
        List<ContentVersion> contentVersions;
        List<String> contentIDs;
        List<String> url;
        List<ContentDistribution> publicUrl;

        if (results.isEmpty()) return null;

        List<Products> products = new List<Products>();
        SH_Utils.QueryBuilder queryBuilder = new SH_Utils.QueryBuilder();
        SH_Utils.QueryBuilder queryBuilderForImg = new SH_Utils.QueryBuilder();

        for (Product2 product : results) {
            ids.add(product.Id);
        }

        queryBuilder.addSelect('UnitPrice')
                .addSelect('Product2Id')
                .addFrom('PricebookEntry')
                .addWhere('Product2Id')
                .startINBlock();

        for (String ind : ids) {
            url = new List<String>();
            linksIDs = new List<String>();
            contentIDs = new List<String>();
            documentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :ind];

            for (ContentDocumentLink linksID : documentLinks) {
                linksIDs.add(linksID.ContentDocumentId);
            }

            contentVersions = [SELECT Id FROM ContentVersion WHERE ContentDocumentId IN :linksIDs AND FileType IN ('JPG', 'JPEG', 'PNG')];

            for (ContentVersion contentID : contentVersions) {
                contentIDs.add(contentID.Id);
            }

            rates.add((Decimal) ([SELECT AVG(Rating__c) averageRating FROM MovieOpinion__c WHERE MovieID__c LIKE :ind].get(0).get('averageRating')));

            publicUrl = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId = :contentIDs];

            for (ContentDistribution imgURL : publicUrl) {
                if (!publicUrl.isEmpty()) url.add(imgURL.ContentDownloadUrl);
                else url.add(null);
            }
            queryBuilder.addWhere('\'' + ind + '\',');
            urls.add(url);
        }

        queryBuilder.addWhere('\'' + ids[0] + '\'')
                .closeBlock();

        List<PricebookEntry> prices = Database.query(queryBuilder.buildQuery());

        for (Integer i = 0; i < ids.size(); i++) {
            products.add(new Products(ids[i], rates[i], results[i], prices, urls[i]));
        }

        return JSON.serialize(products);
    }

    public static List<Product2> prepareProductList(String jsonCredentialsObject) {
        CredentialsObject credentialsObject = (CredentialsObject) System.JSON.deserialize(jsonCredentialsObject, CredentialsObject.class);
        SH_Utils.QueryBuilder query = new SH_Utils.QueryBuilder();

        query.addSelect('Id')
                .addSelect('Name')
                .addSelect('Author__c')
                .addSelect('Description')
                .addSelect('ReleaseDate__c')
                .addSelect('BookType__c')
                .addSelect('MovieType__c')
                .addSelect('Family')
                .addSelect('RecordType.Name')
                .addFrom('Product2')
                .addWhere('Name LIKE \'%' + credentialsObject.searchText + '%\'').addAND()
                .addWhere('Family LIKE \'%' + credentialsObject.searchConditions + '%\'').addAND()
                .addWhere('Author__c LIKE \'%' + credentialsObject.searchAuthor + '%\'');

        if (credentialsObject.searchBook && credentialsObject.searchMovie) {
            query.startANDBlock()
                    .addWhere('RecordType.Name LIKE \'Book\'').addOR()
                    .addWhere('RecordType.Name LIKE \'Movie\'').closeBlock();
        } else {
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
        public Decimal rate;
        public Decimal price = 0;
        public Decimal salePrice;
        public Product2 product;
        public List<String> imgUrls;

        public Products(String ind, Decimal rate, Product2 product, List<PricebookEntry> prices, List<String> imgUrls) {
            this.ind = ind;
            this.rate = rate;
            this.product = product;
            this.imgUrls = imgUrls;

            selectPrice(prices);
        }

        private void selectPrice(List<PricebookEntry> prices) {
            for (PricebookEntry price : prices) {
                if (price.Product2Id == this.ind) {
                    if (price.UnitPrice > this.price) {
                        this.price = price.UnitPrice;

                        if (this.salePrice == null) this.salePrice = price.UnitPrice;
                    } else if (this.salePrice != null && price.UnitPrice < this.salePrice) {
                        this.salePrice = price.UnitPrice;
                    }

                    System.debug(this.ind + ' - ' + this.price);
                }
            }

            if (this.price == this.salePrice) {
                this.salePrice = null;
            }
        }
    }

    public class AllPickListsValueObject {
        public List<String> allBookGenre;
        public List<String> allMovieGenre;
        public List<String> allBookType;
        public List<String> allMovieType;
        public List<String> allConditions;

        public AllPickListsValueObject(List<String> allBookGenre, List<String> allMovieGenre, List<String> allBookType, List<String> allMovieType, List<String> allConditions) {
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