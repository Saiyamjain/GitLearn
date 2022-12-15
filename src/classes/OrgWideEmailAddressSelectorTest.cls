@IsTest
private class OrgWideEmailAddressSelectorTest {
    @IsTest
    private static void testSelectByEmailAddress() {
        OrgWideEmailAddressSelector.newInstance().selectByEmailAddress(null);
    }
}