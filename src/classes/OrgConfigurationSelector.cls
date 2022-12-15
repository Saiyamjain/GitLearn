public inherited sharing class OrgConfigurationSelector extends MetadataSelector {
    public static OrgConfigurationSelector newInstance() {
        return (OrgConfigurationSelector) Application.Selector.newInstance(Org_Configuration__mdt.SObjectType);
    }

    public Org_Configuration__mdt selectMainConfig() {
        return Org_Configuration__mdt.getInstance('Main_Config');
    }
}