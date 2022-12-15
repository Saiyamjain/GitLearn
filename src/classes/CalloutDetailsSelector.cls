public with sharing class CalloutDetailsSelector extends MetadataSelector {

    public static CalloutDetailsSelector newInstance() {
        return (CalloutDetailsSelector) Application.Selector.newInstance(Callout_Details__mdt.SObjectType);
    }
    
    public Callout_Details__mdt selectByDeveloperName(String developerName) {
        return Callout_Details__mdt.getInstance(developerName);
    }

}