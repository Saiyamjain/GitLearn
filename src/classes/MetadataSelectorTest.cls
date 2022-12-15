@IsTest
private class MetadataSelectorTest {
    @IsTest
    static void getSObjectFieldListTest() {
        MetadataSelector ms = new MetadataSelector();
        List<Schema.SObjectField> fieldList = ms.getSObjectFieldList();

        System.assertEquals(null, fieldList);
    }

    @IsTest
    static void getSObjectTypeTest() {
        MetadataSelector ms = new MetadataSelector();
        Schema.SObjectType sObjType = ms.getSObjectType();

        System.assertEquals(null, sObjType);
    }
}