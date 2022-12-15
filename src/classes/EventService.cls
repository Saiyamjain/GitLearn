public with sharing class EventService extends Api.Service {
    private static Integer STATUS_CODE = 400;
    
    public override Api.Response doPost(ApiRequestResolver resolver) {
        EventServiceWrapper esw = new EventServiceWrapper();
        esw.resolver = resolver;
        try {
            validateDuplicateRequest(esw);
            validatePathParameter(esw);
            deserializeRequestBody(esw);
            validatePayload(esw);
            setResponseInsertLogAndEvent(esw);
        } catch (Exception e) {
            setResponseAndLogFailure(esw, e);
            return esw.response;
        }
        return esw.response;
    }
    
    public void validatePathParameter(EventService.EventServiceWrapper esw) {
        EventDomain eventDomain = (EventDomain)Application.Domain.newInstance(new List<Event__c>{esw.event});
        String eventTypes = JSON.serialize(eventDomain.getPicklistEntries(Schema.Event__c.Type__c, null)).replaceAll('\\[|]|"','');
        String arguments = eventTypes.replace(',','|');
        String template = '(?i)^({0})$';
        String regex = String.format(template,new List<String>{arguments});
        if (!Pattern.compile(regex).matcher(esw.resolver.pathParameter).matches()) {
            Api.Response response = new Api.Response();
            response
                .setStatus(STATUS_CODE)
                .setDeveloperMessage(String.format(System.Label.InvalidPathParameter,new List<String>{eventTypes}));
            throw new Api.ApiException(JSON.serialize(response));
        }
    }

    public void validateDuplicateRequest(EventService.EventServiceWrapper esw) {
        String correlationId = esw.resolver.correlationId;
        if (String.isNotBlank(correlationId)) {
            LoggerService.newInstance().logApiInbound(esw.apiLog)?.setRequest(esw.resolver.requestBody);
        } else {
            Api.Response response = new Api.Response();
            response
                    .setStatus(STATUS_CODE)
                    .setDeveloperMessage(System.Label.MissingCorrelationId);
            throw new Api.ApiException(JSON.serialize(response));
        }
    }

    public void deserializeRequestBody(EventService.EventServiceWrapper esw) {
        try {
            if (esw.resolver.pathParameter.equalsIgnoreCase(EventDomain.EventType.CUSTOMERCREATED.name())) {
                esw.payload = (EventDomain.IPayload)JSON.deserialize(esw.resolver.requestBody, EventDomain.CustomerPayload.class);
                esw.event.Type__c = EventDomain.EventType.CUSTOMERCREATED.name();
                esw.event.Name = esw.payload.getIdentifier();
                esw.event.Record_Type__c = ((EventDomain.CustomerPayload)esw.payload).getRecordType();
            } else if (esw.resolver.pathParameter.equalsIgnoreCase(EventDomain.EventType.CUSTOMERUPDATED.name())) {
                esw.payload = (EventDomain.IPayload)JSON.deserialize(esw.resolver.requestBody, EventDomain.CustomerPayload.class);
                esw.event.Type__c = EventDomain.EventType.CUSTOMERUPDATED.name();
                esw.event.Name = esw.payload.getIdentifier();
                esw.event.Record_Type__c = ((EventDomain.CustomerPayload)esw.payload).getRecordType();
            } else if (esw.resolver.pathParameter.equalsIgnoreCase(EventDomain.EventType.LEADCREATED.name())) {
                esw.payload = (EventDomain.IPayload)JSON.deserialize(esw.resolver.requestBody, EventDomain.LeadPayload.class);
                esw.event.Type__c = EventDomain.EventType.LEADCREATED.name();
                esw.event.Name = esw.payload.getIdentifier();
            } else if (esw.resolver.pathParameter.equalsIgnoreCase(EventDomain.EventType.ORDERCREATED.name())) {
                esw.payload = (EventDomain.IPayload)JSON.deserialize(esw.resolver.requestBody, EventDomain.OrderPayload.class);
                esw.event.Type__c = EventDomain.EventType.ORDERCREATED.name();
                esw.event.Name = esw.payload.getIdentifier();
            } else if (esw.resolver.pathParameter.equalsIgnoreCase(EventDomain.EventType.ORDERUPDATED.name())) {
                esw.payload = (EventDomain.IPayload)JSON.deserialize(esw.resolver.requestBody, EventDomain.OrderPayload.class);
                esw.event.Type__c = EventDomain.EventType.ORDERUPDATED.name();
                esw.event.Name = esw.payload.getIdentifier();
            }
        } catch (Exception e) {
            Api.Response response = new Api.Response();
            response
                .setStatus(STATUS_CODE)
                .setMessage(System.Label.InvalidRequestBody)
                .setDeveloperMessage(e.getMessage());
            throw new Api.ApiException(JSON.serialize(response));
        }
    } 

    public void validatePayload(EventService.EventServiceWrapper esw) {
        try {
            for (SObject record : esw.payload.getRecords()) {
                Schema.SObjectType sObjectType = record?.getSObjectType();
                String apexType = 'List<' + sObjectType + '>';
                List<SObject> records = (List<SObject>)Type.forName(apexType).newInstance();
                records.add(record);
                ApplicationDomain domain = (ApplicationDomain) Application.Domain.newInstance(records);
                domain
                    .validateRequiredSObjectFieldsForExternal(esw)
                    .validateSObjectFieldLength()
                    .validateSObjectFieldValues(esw.event.Record_Type__c);
                if (esw.shouldValidateDuplicationRules()) {
                    domain.validateSObjectDuplicationRules();
                }
            }
            validateRecordsToUpdateExist(esw);
        } catch (Exception e) {
            Api.Response response = new Api.Response();
            response
                .setStatus(STATUS_CODE)
                .setDeveloperMessage(e.getMessage());
            throw new Api.ApiException(JSON.serialize(response));
        }
    }

    public void validateRecordsToUpdateExist(EventService.EventServiceWrapper esw) {
        try {
            if (esw.resolver.pathParameter.equalsIgnoreCase(EventDomain.EventType.CUSTOMERUPDATED.name())) {
                EventDomain.AccountValidator accountValidator = new EventDomain.AccountValidator(esw);
                accountValidator.validateRecordExists();
            } else if (esw.resolver.pathParameter.equalsIgnoreCase(EventDomain.EventType.ORDERUPDATED.name())) {
                EventDomain.OrderValidator orderValidator = new EventDomain.OrderValidator(esw);
                orderValidator.validateRecordExists();
            }
        } catch (Exception e) {
            STATUS_CODE = 404;
            Api.Response response = new Api.Response();
            response
                    .setStatus(STATUS_CODE)
                    .setDeveloperMessage(e.getMessage());
            throw new Api.ApiException(JSON.serialize(response));
        }
    }

    public void setResponseInsertLogAndEvent(EventService.EventServiceWrapper esw) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        esw.response
            .setStatus(200)
            .setDeveloperMessage(String.format(System.Label.SuccessMessage,new List<String>{esw.event.Name}));
        LoggerService.newInstance().logApiInbound(esw.apiLog)
            ?.setCalloutEndpoint(esw.resolver.requestUri)
            .setResponse(JSON.serialize(esw.response))
            .setResponseCode(esw.response.status);
        uow.registerNew(esw.event);
        uow.registerNew(esw.apiLog, API_Log__c.Process_ID__c, esw.event);
        uow.commitWork();
    }

    public void setResponseAndLogFailure(EventService.EventServiceWrapper esw, Exception e) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        esw.response = (Api.Response)JSON.deserialize(e.getMessage(), Api.Response.class);
        LoggerService.newInstance().logApiInbound(esw.apiLog)
            ?.setCalloutEndpoint(esw.resolver.requestUri)
            .setResponse(e.getMessage())
            .setResponseCode(esw.response.status);
        uow.registerNew(esw.apiLog);
        uow.commitWork();
    } 

    public static EventService newInstance() {
        return (EventService) Application.Service.newInstance(EventService.class);
    }

    public class EventServiceWrapper {
        public EventDomain.IPayload payload;
        public ApiRequestResolver resolver {
            get {
                if (resolver == null) {
                    resolver = new ApiRequestResolver();
                }
                return resolver;
            }
            set;
        }
        public Event__c event {
            get {
                if (event == null) {
                    event = new Event__c();
                }
                return event;
            }
            set;
        }
        public API_Log__c apiLog {
            get {
                if (apiLog == null) {
                    apiLog = new API_Log__c();
                }
                return apilog;
            }
            set;
        }
        public Api.Response response  {
            get {
                if (response == null) {
                    response = new Api.Response();
                }
                return response;
            }
            set;
        }

        public Boolean isUpdateEventType() {
            List<String> updateEventTypes = new List<String> {
                EventDomain.EventType.CUSTOMERUPDATED.name(), EventDomain.EventType.ORDERUPDATED.name()
            };
            return updateEventTypes.contains(event?.Type__c);
        }

        public Boolean shouldValidateDuplicationRules() {
            List<String> updateEventTypes = new List<String> {
                EventDomain.EventType.CUSTOMERCREATED.name(), EventDomain.EventType.LEADCREATED.name(),
                EventDomain.EventType.ORDERCREATED.name()
            };
            return updateEventTypes.contains(event?.Type__c);
        }

        public Boolean shouldValidateRestrictedPicklistValues() {
            List<String> eventsToValidate = new List<String> {
                    EventDomain.EventType.CUSTOMERCREATED.name(),
                    EventDomain.EventType.CUSTOMERUPDATED.name()
            };
            return eventsToValidate.contains(event?.Type__c);
        }
    }
}