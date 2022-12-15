public inherited sharing class AssignmentRuleSelector extends fflib_SObjectSelector {
    public static AssignmentRuleSelector newInstance() {
        return (AssignmentRuleSelector) Application.Selector.newInstance(AssignmentRule.getSObjectType());
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            AssignmentRule.Id,
            AssignmentRule.Name,
            AssignmentRule.Active
        };
    }

    public Schema.SObjectType getSObjectType() {
        return AssignmentRule.getSObjectType();
    }

    public List<AssignmentRule> selectLeadAssignmentRulesByName(String name) {
        return Database.query(
            newQueryFactory()
                .setCondition('SobjectType =\'Lead\' AND Name =: name')
                .toSOQL());
    }

}