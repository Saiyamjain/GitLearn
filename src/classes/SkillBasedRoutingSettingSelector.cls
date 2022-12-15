public with sharing class SkillBasedRoutingSettingSelector extends MetadataSelector  {

    public static SkillBasedRoutingSettingSelector newInstance() {
        return (SkillBasedRoutingSettingSelector) Application.Selector.newInstance(Skill_Based_Routing_Setting__mdt.SObjectType);
    }

    public Skill_Based_Routing_Setting__mdt selectDefault() {
        return Skill_Based_Routing_Setting__mdt.getInstance('Default');
    }
}