public inherited sharing class AgentWorkDomain extends ApplicationDomain {
    public static AgentWorkDomain newInstance(List<AgentWork> recordList) {
        return (AgentWorkDomain) Application.Domain.newInstance(recordList);
    }

    public AgentWorkDomain(List<AgentWork> agentWorks) {
        super(agentWorks);
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        updateCaseStatusWhenWorkItemAccepted(existingRecords);
    }

    public void updateCaseStatusWhenWorkItemAccepted(Map<Id,SObject> existingRecords) {
        List<Case> casesToUpdate = new List<Case>();
        Set<Id> relatedCasesIds = new Set<Id>();
        for (AgentWork agentWork : (List<AgentWork>)this.records) {
            if (agentWork.WorkItemId.getSobjectType().getDescribe().getName() == 'Case'
                    && ((AgentWork) existingRecords.get(agentWork.Id)).Status != agentWork.Status && agentWork.Status == 'Opened' ) {
                relatedCasesIds.add(agentWork.WorkItemId);
            }
        }
        for (Case relatedCase : CaseSelector.newInstance().selectById(relatedCasesIds)) {
            if (relatedCase.Status == 'Open') {
                relatedCase.Status = 'In Progress';
                casesToUpdate.add(relatedCase);
            }
        }
        if (!casesToUpdate.isEmpty()) {
            fflib_ISObjectUnitOfWork uow = (fflib_ISObjectUnitOfWork)Application.UnitOfWork.newInstance();
            uow.registerDirty(casesToUpdate);
            uow.commitWork();
        }
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AgentWorkDomain(sObjectList);
        }
    }
}