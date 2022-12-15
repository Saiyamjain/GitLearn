public with sharing class QueueableArticleUpsertHandler implements Queueable, Database.AllowsCallouts {
    public static Integer NUMBER_OF_MAX_PROCESSED_ARTICLES_IN_SCOPE = 5;
    private List<Knowledge__kav> articles = new List<Knowledge__kav>();
    private Map<Id, Knowledge__kav> articlesByKnowledgeArticleId = new Map<Id, Knowledge__kav>();
    private Set<Id> articleIds = new Set<Id>();

    public QueueableArticleUpsertHandler(Set<Id> articleIds) {
        this.articleIds = articleIds;
    }

    private QueueableArticleUpsertHandler(List<Knowledge__kav> articles, Map<Id, Knowledge__kav> articlesByKnowledgeArticleId) {
        this.articles = articles;
        this.articlesByKnowledgeArticleId = articlesByKnowledgeArticleId;
    }

    public void execute(QueueableContext sc) {
        if (articles.isEmpty()) {
            articles = KnowledgeSelector.newInstance().selectById(articleIds);
            for (Knowledge__kav article : articles) {
                articlesByKnowledgeArticleId.put(article.KnowledgeArticleId, null);
            }

            for (Knowledge__kav article : KnowledgeSelector.newInstance().selectByKnowledgeArticleIdWithExistingDataCategory(articlesByKnowledgeArticleId.keySet())) {
                articlesByKnowledgeArticleId.put(article.KnowledgeArticleId, article);
            }
        }
        List<Knowledge__kav> articlesToProcess = new List<Knowledge__kav>();
        while (!articles.isEmpty() && articlesToProcess.size() < NUMBER_OF_MAX_PROCESSED_ARTICLES_IN_SCOPE) {
            articlesToProcess.add(articles.remove(0));
        }
        List<API_Log__c> apiLogsToInsert = new List<API_Log__c>();
        List<Exception_Log__c> exceptionLogsToInsert = new List<Exception_Log__c>();
        for (Knowledge__kav article : articlesToProcess) {
            try {
                RestCalloutService request = sendArticleToD3(article);
                apiLogsToInsert.add(request.getApiLog());
            }
            catch (Exception e) {
                exceptionLogsToInsert.add(LoggerService.logException(e)
                    .setExceptionMessage('While processing Knowledge__kav with Id: ' + article.Id + '\n' + e.getMessage())
                    .setClassName('QueueableArticleHandler')
                    .setMethodName('execute')
                    .getExceptionLog());
            }
        }
        if (!apiLogsToInsert.isEmpty() || !exceptionLogsToInsert.isEmpty()) {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(apiLogsToInsert);
            uow.registerNew(exceptionLogsToInsert);
            uow.commitWork();
        }
        if (!articles.isEmpty()) {
            System.enqueueJob(new QueueableArticleUpsertHandler(articles, articlesByKnowledgeArticleId));
        }
    }

    public RestCalloutService sendArticleToD3(Knowledge__kav article) {
        String body = transformBody(article);
        RestCalloutService request = RestCalloutService.newInstance().post()
            ?.setCalloutDetails(RestCalloutService.CALLOUT_DETAILS_ARTICLE_UPSERT_NAME)
            .setJsonHeaderContentType()
            .setBody(body)
            .setProcessId(article.Id)
            .send(false);
        return request;
    }

    private String transformBody(Knowledge__kav article) {
        String body = JSON.serialize(article);
        if (!article.IsMasterLanguage && article.PublishStatus == KnowledgeService.PUBLICATION_STATUS_DRAFT) {
            body = body.replace('"PublishStatus":"Draft"', '"PublishStatus":"Online"');
        }
        if (articlesByKnowledgeArticleId.get(article.KnowledgeArticleId)?.DataCategorySelections?.isEmpty() == false) {
            Knowledge__kav articleWithDataCategories = articlesByKnowledgeArticleId.get(article.KnowledgeArticleId);
            String dataCategoriesJSON = JSON.serialize(articleWithDataCategories.DataCategorySelections);
            body = body.removeEnd('}') + ', "DataCategorySelections": { "records": ' + dataCategoriesJSON + '}}';
        }
        return body;
    }

    public static void enqueue(List<Knowledge__kav> articles) {
        System.enqueueJob(new QueueableArticleUpsertHandler(new Map<Id, Knowledge__kav>(articles).keySet()));
    }
}