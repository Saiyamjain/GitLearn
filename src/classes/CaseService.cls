public with sharing class CaseService {

    public static final String RECORD_TYPE_NAME_EXCO_COMPLAINT = 'Exco Complaint';
    public enum CaseActionType {BILLING_ESCALATION, TECH_ESCALATION, ON_HOLD_ESCALATION, BACK_TO_QUEUE, SPLIT_CASE, CLOSE}

    public static CaseService newInstance() {
        return (CaseService) Application.Service.newInstance(CaseService.class);
    }

    public void performCaseActions(CaseService.CaseActionWrapper caw) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<Case> caseRecords =
            CaseSelector.newInstance().selectByIdWithFieldsForCloningRecord(new Set<Id> { caw.caseId });

        if (caseRecords.size() != 1) {
            throw new Application.ApplicationException(Label.No_Records_Found);
        }

        caw.setCaseQueueAssignmentByCountryCode(CaseQueueAssignmentSelector.newInstance().selectAll());
        CaseDomain cases = CaseDomain.newInstance(caseRecords);
        Case currentCase = caseRecords.get(0);
        cases.setCaseActionFields(caw.caseAction, caw.caseActionReason);

        if (caw.isActionWithResponse() || caw.caseActionType == CaseService.CaseActionType.BACK_TO_QUEUE) {
            cases
                .setStatusField('Open')
                .setQueueKeyField(caw.queueKey)
                .setOwnerIdForCaseAction(caw);
            if (caw.isActionWithResponse()) {
                cases.setLastCaseCommentField(caw.response);
                if (String.isNotBlank(caw.response)) {
                    cases.createCaseComment(uow, caw.response.replaceAll('</p>', '\n').replaceAll('<[^>]+>',' '));
                    cases.sendEmailWithCaseActionsResponse(uow, currentCase, caw.response);
                }
            }
        } else {
            cases
                .setStatusField('Closed')
                .setOwnerToCurrentUser();
            if (caw.caseActionType == CaseService.CaseActionType.SPLIT_CASE) {
                cases.cloneCase(uow, new Map<String, Object> {
                    'Status' => 'Open',
                    'Queue_Key__c' => caw.queueKey,
                    'OwnerId' => cases.getOwnerIdForCaseAction(currentCase, caw)
                });
            }
        }
        uow.registerDirty(currentCase);
        uow.commitWork();
    }

    public Id getQueueId(Case c) {
        Id groupId;
        Case_Queue_Assignment__mdt caseQueueAssignment =
                CaseQueueAssignmentSelector.newInstance().selectAll().get(c.Notification_Country_Code__c);
        String queueName = c.RecordTypeId == Utils.getRecordTypeId(Case.SObjectType, CaseService.RECORD_TYPE_NAME_EXCO_COMPLAINT) ?
                CaseService.RECORD_TYPE_NAME_EXCO_COMPLAINT : caseQueueAssignment?.New_Cases__c.trim();
        if (queueName != null) {
            groupId = GroupSelector.newInstance().selectByTypeAndName('Queue', queueName)[0].Id;
        }
        return groupId;
    }

    public class CaseActionWrapper {
        public final List<CaseService.CaseActionType> ACTIONS_WITH_RESPONSE = new List<CaseService.CaseActionType> {
            CaseService.CaseActionType.BILLING_ESCALATION,
            CaseService.CaseActionType.ON_HOLD_ESCALATION,
            CaseService.CaseActionType.TECH_ESCALATION
        };

        public final Map<CaseService.CaseActionType, String> CASE_ACTION_TO_CASE_QUEUE_ASSIGNMENT_FIELD = new Map<CaseService.CaseActionType, String> {
            CaseService.CaseActionType.BILLING_ESCALATION => 'Billing_Cases__c',
            CaseService.CaseActionType.TECH_ESCALATION => 'Tech_Cases__c',
            CaseService.CaseActionType.ON_HOLD_ESCALATION => 'On_Hold_Cases__c',
            CaseService.CaseActionType.BACK_TO_QUEUE => 'New_Cases__c',
            CaseService.CaseActionType.SPLIT_CASE => 'New_Cases__c'
        };

        public final Map<CaseService.CaseActionType, Integer> CASE_ACTION_TO_QUEUE_KEY = new Map<CaseService.CaseActionType, Integer> {
            CaseService.CaseActionType.BILLING_ESCALATION => 3,
            CaseService.CaseActionType.TECH_ESCALATION => 2,
            CaseService.CaseActionType.ON_HOLD_ESCALATION => 1,
            CaseService.CaseActionType.BACK_TO_QUEUE => 0,
            CaseService.CaseActionType.SPLIT_CASE => 0
        };

        @AuraEnabled
        public String caseId { get; set; }
        @AuraEnabled
        public String caseAction { get; set; }
        @AuraEnabled
        public String caseActionReason { get; set; }
        @AuraEnabled
        public String response { get; set; }

        @TestVisible
        public CaseActionType caseActionType {
            get {
                if (this.caseActionType == null) {
                    if (String.isNotBlank(caseAction)) {
                        this.caseActionType = toCaseActionType(caseAction);
                    }
                }
                return this.caseActionType;
            }
            private set;
        }

        public Integer queueKey {
            get {
                if (this.queueKey == null) {
                    this.queueKey = CASE_ACTION_TO_QUEUE_KEY.get(caseActionType);
                }
                return this.queueKey;
            }
            private set;
        }

        public String caseQueueAssignmentField {
            get {
                if (this.caseQueueAssignmentField == null) {
                    this.caseQueueAssignmentField = CASE_ACTION_TO_CASE_QUEUE_ASSIGNMENT_FIELD.get(caseActionType);
                }
                return this.caseQueueAssignmentField;
            }
            private set;
        }

        public Map<String, Id> queueByQueueId {
            get {
                if (this.queueByQueueId == null) {
                    queueByQueueId = new Map<String, Id>();
                    for (Group queue : GroupSelector.newInstance().selectByType('Queue')) {
                        queueByQueueId.put(queue.Name, queue.Id);
                    }
                }
                return this.queueByQueueId;
            }
            private set;
        }

        public Map<String, Case_Queue_Assignment__mdt> caseQueueAssignmentByCountryCode;

        public Boolean isActionWithResponse() {
            return ACTIONS_WITH_RESPONSE.contains(caseActionType);
        }

        public void setCaseQueueAssignmentByCountryCode(Map<String, Case_Queue_Assignment__mdt> caseQueueAssignmentByCountryCode) {
            this.caseQueueAssignmentByCountryCode = caseQueueAssignmentByCountryCode;
        }
    }

    public static CaseActionType toCaseActionType(String s) {
        for (CaseActionType caseActionType : CaseActionType.values()) {
            if (caseActionType.name().equalsIgnoreCase(s.replaceAll('[^a-zA-Z]', '_'))) {
                return caseActionType;
            }
        }
        return null;
    }
}