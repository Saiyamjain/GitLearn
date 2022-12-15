public inherited sharing class BotIntentCaseMappingSelector extends MetadataSelector {
    public static BotIntentCaseMappingSelector newInstance() {
        return (BotIntentCaseMappingSelector) Application.Selector.newInstance(Bot_Intent_Case_Mapping__mdt.SObjectType);
    }

    public Bot_Intent_Case_Mapping__mdt selectByDeveloperName(String name) {
        return Bot_Intent_Case_Mapping__mdt.getInstance(name);
    }

    public Map<String, Bot_Intent_Case_Mapping__mdt> selectAll() {
        return Bot_Intent_Case_Mapping__mdt.getAll();
    }
}