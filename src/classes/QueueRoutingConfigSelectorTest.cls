@IsTest(IsParallel=true)
private class QueueRoutingConfigSelectorTest {
    @IsTest
    static void getConfigbyDeveloperName() {
        String CaseRoutingConfigName = 'Web';
        QueueRoutingConfig result = QueueRoutingConfigSelector.newInstance().getConfigbyDeveloperName(CaseRoutingConfigName);
        System.assert(result != null);
    }

    @IsTest
    static void getListbyDeveloperName() {
        Set<String> originsToRoute = new Set<String>{
            'Web', 'Email'
        };
        List<QueueRoutingConfig> result = QueueRoutingConfigSelector.newInstance().getListbyDeveloperName(originsToRoute);
        System.assert(result.size() > 0);
    }
}