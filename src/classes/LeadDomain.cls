public inherited sharing class LeadDomain extends ApplicationDomain {
    private static final String BUSINESS_TYPE_HOTELROOM = 'Hotel';
    private static final String BUSINESS_TYPE_KARAOKE = 'Karaoke';
    private static final String BUSINESS_TYPE_OFFICE = 'Office';
    private static final String INTEGRATION_USER = 'dl-daznsalesforce@dazn.com.b2b';

    public static LeadDomain newInstance(List<Lead> recordList) {
        return (LeadDomain) Application.Domain.newInstance(recordList);
    }

    public LeadDomain(List<Lead> leads) {
        super(leads);
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        changeStatusToOpenIfOwnerChangedFromQueueToUser();
    }

    public override void onAfterInsert() {
        sendEmailNotificationsForLeadsFromApi();
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        new LeadDomainElevatedContext().trackSObjectHistory((List<Lead>)this.records);
    }

    public override void onValidate() {
        reportIfRequiredLeadFieldsAreMissing();
    }

    public override void onValidate(Map<Id, SObject> existingRecords) {
        reportIfRequiredLeadFieldsAreMissing();
    }

    private void reportIfRequiredLeadFieldsAreMissing() {
        if (System.Request.getCurrent().getQuiddity() == System.Quiddity.REST) {
            reportIfRequiredFieldsAreMissing();
        }
    }

    // TODO: Jens - 20-06-2022 - I believe this method should be replaced by a flow that send an email instead
    public void sendEmailNotificationsForLeadsFromApi() {
        try {
            OrgWideEmailAddress emailForSendingNotifications = OrgWideEmailAddressSelector.newInstance().selectByEmailAddress(DAZNConfigurationSelector.newInstance().selectByEnvType().Email_Address_For_Lead_Actions__c);
            if (emailForSendingNotifications == null) {
                return;
            }

            List<New_Integration_Lead_Notification__mdt> mailsForNotifications = NewIntegrationLeadNotificationSelector.newInstance().getAll();
            if (mailsForNotifications.isEmpty()) {
                return;
            }

            if (UserInfo.getUserName().startsWithIgnoreCase(INTEGRATION_USER)) { // Should only be sent when creatd from api
                List<Messaging.Email> emailsToSend = new List<Messaging.Email>();
                String emailTemplateNamePrefix = 'New Integration Lead';
                Map<String, EmailTemplate> emailTemplatesByLanguageCode = new Map<String, EmailTemplate>();
                for (EmailTemplate emailTemplate : EmailTemplateSelector.newInstance().selectWhereNameStartsWith(emailTemplateNamePrefix)) {
                    emailTemplatesByLanguageCode.put(
                            emailTemplate.Name.remove(emailTemplateNamePrefix).trim(),
                            emailTemplate
                    );
                }
                for (Lead lead : (List<Lead>) this.Records) {
                    for (New_Integration_Lead_Notification__mdt mailForNotification : mailsForNotifications) {
                        if (emailTemplatesByLanguageCode.containsKey(mailForNotification.Language__c) && mailForNotification.country__c == lead.Country__c) {
                            EmailTemplate emailTemplate = emailTemplatesByLanguageCode.get(mailForNotification.Language__c);
                            Messaging.SingleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, null);
                            emailMessage.setOrgWideEmailAddressId(emailForSendingNotifications.Id);
                            emailMessage.setToAddresses(new List<String>{
                                    mailForNotification.Email__c
                            });
                            emailMessage.setHtmlBody(
                                    emailTemplate.HtmlValue
                                            .replace('{!Lead.Company}', lead.Company)
                                            .replace('{!Lead.Name}', getLeadName(lead))
                                            .replace('{!Lead.Link}', '<a href="' + Url.getSalesforceBaseUrl().toExternalForm() + '/' + lead.Id + '">Lead</a>')
                            );
                            emailsToSend.add(emailMessage);
                        }
                    }
                }
                Messaging.sendEmail(emailsToSend);
            }
        }
        catch (Exception e) {
            List<Id> affectedIds = new List<Id>();
            for (SObject record : Records) {
                affectedIds.add(record.Id);
            }
            LoggerService.logException(e)
                    .setClassName('LeadDomain')
                    .setMethodName('sendEmailNotificationsForLeadsFromApi')
                    .doInsertExceptionLog();
        }
    }

    private String getLeadName(Lead lead) {
        return ((String.isNotBlank(lead.FirstName) ? lead.FirstName : '') + ' ' + (String.isNotBlank(lead.LastName) ? lead.LastName : '')).trim();
    }

    public void changeStatusToOpenIfOwnerChangedFromQueueToUser() {
        Map<Id, Group> leadsQueuesById = new Map<Id, Group>();
        for (Group groupToFilter : GroupSelector.newInstance().selectByType('Queue')) {
            if (groupToFilter.Name.containsIgnoreCase('leads')) {
                leadsQueuesById.put(groupToFilter.Id, groupToFilter);
            }
        }

        if (!leadsQueuesById.isEmpty()) {
            Map<Id, Lead> oldLeadsMap = (Map<Id, Lead>) this.ExistingRecords;
            for (Lead updatedLead : (List<Lead>) this.Records) {
                Lead oldLead = oldLeadsMap.get(updatedLead.Id);
                if (oldLead.Status.equalsIgnoreCase('open') &&
                        oldLead.OwnerId != updatedLead.OwnerId &&
                        oldLead.Status == updatedLead.Status &&
                        leadsQueuesById.containsKey(oldLead.OwnerId) &&
                        String.valueOf(updatedLead.OwnerId).startsWith('005')) {
                    updatedLead.Status = 'In progress';
                }
            }
        }
    }

    public override ApplicationDomain validateRequiredSObjectFieldsForExternal(EventService.EventServiceWrapper esw) {
        Map<SObjectField, String> requiredFieldsNameBySObjectField = getRequiredFieldsInfoBySObjectType();
        SObjectField leadId = Lead.Lead_Id__c.getDescribe().getSobjectField();
        requiredFieldsNameBySObjectField.put(leadId, String.valueOf(leadId));
        return validateFields(requiredFieldsNameBySObjectField);
        /*
        if(((EventDomain.LeadPayload)esw.payload).leadData.lead.Country__c .equalsIgnoreCase('jp')) {
            requiredFieldsNameBySObjectField = getRequiredFieldsNameBySObjectFieldForJP(esw, requiredFieldsNameBySObjectField);
            return validateBlankFieldsAndInteger(requiredFieldsNameBySObjectField);
        } else {
            return validateFields(requiredFieldsNameBySObjectField);
        }
         */
    }

    // Below method will be invoked only for japan leads
    private Map<SObjectField, String> getRequiredFieldsNameBySObjectFieldForJP(EventService.EventServiceWrapper esw,
            Map<SObjectField, String> requiredFieldsNameBySObjectField){
        SObjectField numberOfRooms      = Lead.Total_number_of_rooms__c.getDescribe().getSobjectField();
        SObjectField numberOfMonitors   = Lead.Total_number_of_monitors__c.getDescribe().getSobjectField();
        SObjectField numberOfVenues     = Lead.Number_of_venues__c.getDescribe().getSobjectField();

        if (((EventDomain.LeadPayload)esw.payload).leadData.lead.Business_Type__c.containsIgnoreCase(BUSINESS_TYPE_HOTELROOM) ||
                ((EventDomain.LeadPayload)esw.payload).leadData.lead.Business_Type__c.containsIgnoreCase(BUSINESS_TYPE_KARAOKE)) {
            requiredFieldsNameBySObjectField.put(numberOfRooms , String.valueOf(numberOfRooms));
        } else if (((EventDomain.LeadPayload)esw.payload).leadData.lead.Business_Type__c.equalsIgnoreCase(BUSINESS_TYPE_OFFICE)) {
            requiredFieldsNameBySObjectField.put(numberOfMonitors, String.valueOf(numberOfMonitors));
        } else {
            requiredFieldsNameBySObjectField.put(numberOfVenues, String.valueOf(numberOfVenues));
        }
        return requiredFieldsNameBySObjectField;
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new LeadDomain(sObjectList);
        }
    }

    public without sharing class LeadDomainElevatedContext {
        public void trackSObjectHistory(List<Lead> records) {
            LeadDomain.newInstance(records).trackSObjectHistory();
        }
    }
}