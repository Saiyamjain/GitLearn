public with sharing class QueueRoutingConfigSelector extends fflib_SObjectSelector {

    public static QueueRoutingConfigSelector newInstance() {
        return (QueueRoutingConfigSelector) Application.Selector.newInstance(QueueRoutingConfig.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            QueueRoutingConfig.DeveloperName,
            QueueRoutingConfig.RoutingPriority,
            QueueRoutingConfig.CapacityWeight
        };
    }

    public Schema.SObjectType getSObjectType() {
        return QueueRoutingConfig.SObjectType;
    }

    public List<QueueRoutingConfig> getListbyDeveloperName(Set<String> nameSet) {
        Set<String> fields = new Set<String> {
            'DeveloperName',
            'CapacityWeight',
            'RoutingPriority'
        };
        return Database.query(
            newQueryFactory()
                .selectFields(fields)
                .setCondition('DeveloperName IN :nameSet')
                .toSOQL()
        );
    }

    public QueueRoutingConfig getConfigbyDeveloperName(String devName) {
        Set<String> fields = new Set<String> {
            'DeveloperName',
            'CapacityWeight',
            'RoutingPriority'
        };
        return Database.query(
            newQueryFactory()
                .selectFields(fields)
                .setCondition('DeveloperName =: devName')
                .toSOQL()
        );
    }
}