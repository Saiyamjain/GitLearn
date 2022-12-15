public inherited sharing class DAZNConfigurationSelector extends MetadataSelector {
    public static DAZNConfigurationSelector newInstance() {
        return (DAZNConfigurationSelector) Application.Selector.newInstance(DAZN_Configuration__mdt.SObjectType);
    }

    public DAZN_Configuration__mdt selectByEnvType() {
        return DAZN_Configuration__mdt.getInstance(OrgConfigurationSelector.newInstance().selectMainConfig().Environment_Type__c);
    }
}