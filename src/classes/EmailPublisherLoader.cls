global class EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        for (QuickAction.QuickActionDefaults actionDefault : defaults) {
            if (actionDefault instanceof QuickAction.SendEmailQuickActionDefaults && actionDefault.getTargetSObject().getSObjectType() == EmailMessage.SObjectType) {
                QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults) actionDefault;
                if (String.valueOf(sendEmailDefaults.getContextId()).startsWith(Case.SObjectType.getDescribe().getKeyPrefix())) {
                    String emailTemplateId = EmailTemplateSelector.newInstance().selectByDeveloperName(EmailMessageService.AGENT_COMMENTED_TEMPLATE_NAME)?.Id;
                    if (String.isNotBlank(emailTemplateId)) {
                        sendEmailDefaults.setTemplateId(emailTemplateId);
                        sendEmailDefaults.setInsertTemplateBody(true);
                        sendEmailDefaults.setIgnoreTemplateSubject(true);
                        EmailMessage emailMessage = (EmailMessage) sendEmailDefaults.getTargetSObject();
                        emailMessage.BccAddress = null;
                        emailMessage.CcAddress = null;
                    }
                }
            }
        }
    }
}