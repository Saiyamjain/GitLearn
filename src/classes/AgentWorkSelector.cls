public class AgentWorkSelector extends fflib_SObjectSelector {
    public static AgentWorkSelector newInstance() {
        return (AgentWorkSelector) Application.Selector.newInstance(AgentWork.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            AgentWork.UserId,
            AgentWork.CapacityWeight,
            AgentWork.Id
        };
    }

    public Schema.SObjectType getSObjectType() {
        return AgentWork.SObjectType;
    }

    public List<AgentWork> selectById(Set<Id> idSet) {
        return (List<AgentWork>) selectSObjectsById(idSet);
    }

    public List<AgentWork> selectOpenedAssignedWork(Set<Id> onlineAgentsIds) {
        Set<String> serviceChannelFields = new Set<String> {
            'ServiceChannel.DeveloperName'
        };
        return Database.query(
                newQueryFactory()
                    .selectFields(serviceChannelFields)
                    .setCondition('Status IN (\'Opened\',\'Assigned\') AND UserId = :onlineAgentsIds')
                    .toSOQL()
        );
    }
}