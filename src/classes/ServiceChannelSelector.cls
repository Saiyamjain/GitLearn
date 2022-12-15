public class ServiceChannelSelector extends fflib_SObjectSelector {
    public static ServiceChannelSelector newInstance() {
        return (ServiceChannelSelector) Application.Selector.newInstance(ServiceChannel.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ServiceChannel.RelatedEntity,
            ServiceChannel.Id
        };
    }

    public Schema.SObjectType getSObjectType() {
        return ServiceChannel.SObjectType;
    }

    public ServiceChannel selectByRelatedEntity(String entity) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('RelatedEntity = :entity');
        query.setLimit(1);
        return (ServiceChannel) Database.query(query.toSOQL());
	}
}