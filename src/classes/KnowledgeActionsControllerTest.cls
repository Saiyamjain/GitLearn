@IsTest
public with sharing class KnowledgeActionsControllerTest {
    @IsTest
    static void testPublishArticleAction() {
        String articleActionType = 'publish';
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        mocks.startStubbing();
        Id knowledgeArticleId = fflib_IDGenerator.generate(Knowledge__kav.SObjectType);
        Set<Id> knowledgeArticleIds = new Set<Id>{
                knowledgeArticleId
        };

        KnowledgeService mockService = (KnowledgeService) mocks.mock(KnowledgeService.class);
        mocks.stopStubbing();
        Application.Service.setMock(KnowledgeService.class, mockService);

        KnowledgeActionsController.callArticleAction(knowledgeArticleId, articleActionType);

        ((KnowledgeService) mocks.verify(mockService, 1)).publishArticles(knowledgeArticleIds);

    }

    @IsTest
    static void testArchiveArticleAction() {
        String articleActionType = 'archive';
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        mocks.startStubbing();
        Id knowledgeArticleId = fflib_IDGenerator.generate(Knowledge__kav.SObjectType);
        Set<Id> knowledgeArticleIds = new Set<Id>{
                knowledgeArticleId
        };

        KnowledgeService mockService = (KnowledgeService) mocks.mock(KnowledgeService.class);
        mocks.stopStubbing();
        Application.Service.setMock(KnowledgeService.class, mockService);

        KnowledgeActionsController.callArticleAction(knowledgeArticleId, articleActionType);
        ((KnowledgeService) mocks.verify(mockService, 1)).archiveArticles(knowledgeArticleIds);

    }

    @IsTest
    static void testRestoreArticleAction() {
        String articleActionType = 'restore';
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        mocks.startStubbing();
        Id knowledgeArticleId = fflib_IDGenerator.generate(Knowledge__kav.SObjectType);
        Set<Id> knowledgeArticleIds = new Set<Id>{
                knowledgeArticleId
        };

        KnowledgeService mockService = (KnowledgeService) mocks.mock(KnowledgeService.class);
        mocks.stopStubbing();
        Application.Service.setMock(KnowledgeService.class, mockService);

        KnowledgeActionsController.callArticleAction(knowledgeArticleId, articleActionType);

        ((KnowledgeService) mocks.verify(mockService, 1)).restoreArticles(knowledgeArticleIds);
    }

    @IsTest
    static void testPublishArticleActionException() {
        String articleActionType = 'publish';
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        mocks.startStubbing();
        Id knowledgeArticleId = fflib_IDGenerator.generate(Knowledge__kav.SObjectType);
        Set<Id> knowledgeArticleIds = new Set<Id>{
                knowledgeArticleId
        };

        KnowledgeService mockService = (KnowledgeService) mocks.mock(KnowledgeService.class);
        ((KnowledgeService) mocks.doThrowWhen(new List<Exception>{
                new Application.ApplicationException('Test exception')
        }, mockService)).publishArticles(knowledgeArticleIds);
        mocks.stopStubbing();
        Application.Service.setMock(KnowledgeService.class, mockService);

        LightningResult result = KnowledgeActionsController.callArticleAction(knowledgeArticleId, articleActionType);

        ((KnowledgeService) mocks.verify(mockService, 1)).publishArticles(knowledgeArticleIds);

        System.assertEquals('Test exception', result.msg.msg);
    }

    @IsTest
    static void testPublishArticlesListButton() {
        Knowledge__kav knowledgeArticle = TestUtils.createAndInsertKnowledgeArticle('publishArticle', 'publish123');

        Test.startTest();
        Test.setCurrentPage(Page.ArchiveArticles);
        List<Knowledge__kav> knowledgeArticlesToPublish = new List<Knowledge__kav>();
        knowledgeArticlesToPublish.add(knowledgeArticle);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(knowledgeArticlesToPublish);
        ssc.setSelected(knowledgeArticlesToPublish);
        KnowledgeActionsController knowledgeActionsController = new KnowledgeActionsController(ssc);
        knowledgeActionsController.publishArticles();
        Test.stopTest();

        List<Knowledge__kav> knowledgeArticles = KnowledgeSelector.newInstance().selectById(new Set<Id>{
                knowledgeArticle.Id
        });

        System.assertEquals('Online', knowledgeArticles.get(0).PublishStatus);
    }

    @IsTest
    static void testArchiveArticlesListButton() {
        Knowledge__kav knowledgeArticle = TestUtils.createAndInsertKnowledgeArticle('archiveArticle', 'archive123');
        KnowledgeSelector knowledgeSelector = new KnowledgeSelector();
        List<Knowledge__kav> draftArticles = knowledgeSelector.selectById(new Set<Id>{
                knowledgeArticle.Id
        });
        KbManagement.PublishingService.publishArticle(draftArticles.get(0).KnowledgeArticleId, true);

        Test.startTest();
        Test.setCurrentPage(Page.ArchiveArticles);
        List<Knowledge__kav> knowledgeArticlesToArchive = new List<Knowledge__kav>();
        knowledgeArticlesToArchive.add(knowledgeArticle);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(knowledgeArticlesToArchive);
        ssc.setSelected(knowledgeArticlesToArchive);
        KnowledgeActionsController knowledgeActionsController = new KnowledgeActionsController(ssc);
        knowledgeActionsController.archiveArticles();
        Test.stopTest();

        List<Knowledge__kav> knowledgeArticles = knowledgeSelector.selectById(new Set<Id>{
                knowledgeArticle.Id
        });

        System.assertEquals('Archived', knowledgeArticles.get(0).PublishStatus);
    }

    @IsTest
    static void testRestoreArticleButton() {
        Knowledge__kav knowledgeArticle = TestUtils.createAndInsertKnowledgeArticle('archiveArticle', 'archive123');
        KnowledgeSelector knowledgeSelector = new KnowledgeSelector();
        List<Knowledge__kav> draftArticles = knowledgeSelector.selectById(new Set<Id>{
                knowledgeArticle.Id
        });
        KbManagement.PublishingService.publishArticle(draftArticles.get(0).KnowledgeArticleId, true);
        KbManagement.PublishingService.archiveOnlineArticle(draftArticles.get(0).KnowledgeArticleId, null);

        Test.startTest();
        Test.setCurrentPage(Page.RestoreArticles);
        List<Knowledge__kav> knowledgeArticlesToRestore = new List<Knowledge__kav>();
        knowledgeArticlesToRestore.add(knowledgeArticle);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(knowledgeArticlesToRestore);
        ssc.setSelected(knowledgeArticlesToRestore);
        KnowledgeActionsController knowledgeActionsController = new KnowledgeActionsController(ssc);
        knowledgeActionsController.restoreArticles();
        Test.stopTest();

        List<Knowledge__kav> knowledgeArticles = knowledgeSelector.selectByKnowledgeArticleId(new Set<Id>{
                draftArticles.get(0).KnowledgeArticleId
        });

        Set<String> articleStatuses = new Set<String>();
        for (Knowledge__kav knowledge : knowledgeArticles) {
            articleStatuses.add(knowledge.PublishStatus);
        }

        System.assert(articleStatuses.contains('Archived'));
        System.assert(articleStatuses.contains('Draft'));
    }

    @IsTest
    static void testRestoreArticlesListButton() {
        Knowledge__kav knowledgeArticle = TestUtils.createAndInsertKnowledgeArticle('archiveArticle', 'archive123');
        Knowledge__kav knowledgeArticle2 = TestUtils.createAndInsertKnowledgeArticle('archiveArticle2', 'archive1232');
        KnowledgeSelector knowledgeSelector = new KnowledgeSelector();
        List<Knowledge__kav> draftArticles = knowledgeSelector.selectById(new Set<Id>{
                knowledgeArticle.Id,
                knowledgeArticle2.Id
        });
        KbManagement.PublishingService.publishArticle(draftArticles.get(0).KnowledgeArticleId, true);
        KbManagement.PublishingService.archiveOnlineArticle(draftArticles.get(0).KnowledgeArticleId, null);
        KbManagement.PublishingService.publishArticle(draftArticles.get(1).KnowledgeArticleId, true);
        KbManagement.PublishingService.archiveOnlineArticle(draftArticles.get(1).KnowledgeArticleId, null);

        Test.startTest();
        Test.setCurrentPage(Page.RestoreArticles);
        List<Knowledge__kav> knowledgeArticlesToRestore = new List<Knowledge__kav>();
        knowledgeArticlesToRestore.add(knowledgeArticle);
        knowledgeArticlesToRestore.add(knowledgeArticle2);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(knowledgeArticlesToRestore);
        ssc.setSelected(knowledgeArticlesToRestore);
        KnowledgeActionsController knowledgeActionsController = new KnowledgeActionsController(ssc);
        knowledgeActionsController.restoreArticles();
        Test.stopTest();

        List<Knowledge__kav> knowledgeArticles = knowledgeSelector.selectByKnowledgeArticleId(new Set<Id>{
                draftArticles.get(0).KnowledgeArticleId
        });

        Set<String> articleStatuses = new Set<String>();
        for (Knowledge__kav knowledge : knowledgeArticles) {
            articleStatuses.add(knowledge.PublishStatus);
        }

        System.assert(articleStatuses.contains('Archived'));
        System.assert(articleStatuses.contains('Draft'));
    }

    @IsTest
    static void getExternalArticleStatusShouldCallService() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        KnowledgeService serviceMock = (KnowledgeService) mocks.mock(KnowledgeService.class);

        // Given
        mocks.startStubbing();
        String knowledgeId = fflib_IDGenerator.generate(Knowledge__kav.SObjectType);
        String resultStatus = 'Archived';
        Set<Id> knowledgeIds = new Set<Id>{knowledgeId};

        mocks.when(serviceMock.getArticlesExternalStatuses(knowledgeIds)).thenReturn(new Map<String, String>{ knowledgeId => resultStatus});
        mocks.stopStubbing();
        Application.Service.setMock(KnowledgeService.class, serviceMock);

        // When
        LightningResult result = KnowledgeActionsController.getExternalArticleStatus(knowledgeId);

        // Then
        ((KnowledgeService) mocks.verify(serviceMock, 1)).getArticlesExternalStatuses(knowledgeIds);
        System.assertEquals(resultStatus, result.result);
    }

    @IsTest
    static void getExternalArticleStatusWithoutRecordIdShouldReturnError() {
        LightningResult result = KnowledgeActionsController.getExternalArticleStatus(null);
        System.assertEquals(LightningResult.MsgVariant.ERROR.name(), result.msg.variant);
    }
}