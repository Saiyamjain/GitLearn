public inherited sharing class OrgWideEmailAddressSelector extends fflib_SObjectSelector {
    public static OrgWideEmailAddressSelector newInstance() {
        return (OrgWideEmailAddressSelector) Application.Selector.newInstance(OrgWideEmailAddress.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            OrgWideEmailAddress.Id,
            OrgWideEmailAddress.Address
        };
    }

    public Schema.SObjectType getSObjectType() {
        return OrgWideEmailAddress.SObjectType;
    }

    public OrgWideEmailAddress selectByEmailAddress(String emailAddress) {
        List<OrgWideEmailAddress> orgWideEmailAddresses = Database.query(
            newQueryFactory()
                .setCondition('Address = :emailAddress')
                .toSOQL()
        );
        return orgWideEmailAddresses.isEmpty() ? null : orgWideEmailAddresses.get(0);
    }
}