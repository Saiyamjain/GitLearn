trigger SkillRequirementTrigger on SkillRequirement (before insert, before update, after insert, after update) {
    fflib_SObjectDomain.triggerHandler(SkillRequirementDomain.class);
}