public inherited sharing class NewIntegrationLeadNotificationSelector extends MetadataSelector {
    public static NewIntegrationLeadNotificationSelector newInstance() {
        return (NewIntegrationLeadNotificationSelector) Application.Selector.newInstance(New_Integration_Lead_Notification__mdt.SObjectType);
    }

    public List<New_Integration_Lead_Notification__mdt> getAll() {
        return New_Integration_Lead_Notification__mdt.getAll().values();
    }
}