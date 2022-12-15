@IsTest
private class OrgConfigurationSelectorTest {
    @IsTest
    private static void testSelectMainConfig() {
        // Query
        Org_Configuration__mdt orgConfiguration =
            OrgConfigurationSelector.newInstance().selectMainConfig();

        // Assert
        System.assert(orgConfiguration != null);
    }
}