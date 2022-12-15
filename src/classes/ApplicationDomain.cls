// TODO - Jens - 18/7/2022 - This entire class should be documented in readme file about fflib libs
public inherited sharing abstract class ApplicationDomain extends fflib_SObjectDomain {   

    Integer MAX_NUMBER_OF_DIGITS_ALLOWED = 16;
    public map<ID,SObject> idInErrorMap = new map<ID,SObject> ();

    public static ApplicationDomain newInstance(List<SObject> recordList) {
        return (ApplicationDomain) Application.Domain.newInstance(recordList);
    }

    public ApplicationDomain(List<SObject> records) {
        super(records);
    }

    // TODO - Jens - 18/7/2022 - Describe this method in readme file of fflib libs
    public override List<SObject> getRecordsWithNotBlankFieldValues(Schema.SObjectField field) {
        return super.getRecordsWithNotBlankFieldValues(field);
    }

    // TODO - Jens - 18/7/2022 - Describe this method in readme file of fflib libs
	public override List<SObject> getRecordsWithNotBlankFieldValues(Set<Schema.SObjectField> fields) {
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords()) {
			for (SObjectField field : fields) {
				if (String.isNotBlank(String.valueOf(record.get(field)))) {
					result.add(record);
					break;
				}
			}
		}
		return result;
	}

    // TODO - Jens - 5/8/2022 - Describe this method in readme file of fflib libs
    public override List<SObject> getRecordsWithBlankFieldValues(Set<Schema.SObjectField> fields) {
		List<SObject> result = new List<SObject>();
		for (SObject record : getRecords()) {
			for (SObjectField field : fields) {
				if (String.isNotBlank(String.valueOf(record.get(field)))) continue;

				result.add(record);
				break;
			}
		}
		return result;
	}

    protected void reportIfRequiredFieldsAreMissing() {
        reportIfRequiredFieldsAreMissing(null);
    }

    protected void reportIfRequiredFieldsAreMissing(String fieldSetAPIName) {
        if (System.Request.getCurrent().getQuiddity() != System.Quiddity.AURA) {
            for (SObject record : getRecords()) {
                String APIName = fieldSetAPIName == null ? getRecordTypeDeveloperName(record) : fieldSetAPIName;
                for (SObjectField field : getRequiredFieldsFromFieldSetByAPIName(APIName)) {
                    if (String.isBlank(String.valueOf(record.get(field)))) {
                        record.addError(field,Label.ValueMissingException); 
                    }
                }
            }
        }
    }

    protected String getRecordTypeDeveloperName(SObject record) {
        return getSObjectType()
            .getDescribe()
            .getRecordTypeInfosById()
            .get((Id)record?.get('RecordTypeId'))
            ?.getDeveloperName();
    }

    private Set<SObjectField> getRequiredFieldsFromFieldSetByAPIName(String fieldSetAPIName){
        Set<SObjectField> fields = new Set<SObjectField>();
        List<Schema.FieldSetMember> fieldSetMembers = getFieldSetMembersByAPIName(fieldSetAPIName);
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers){
            if (fieldSetMember.required) {
                fields.add(fieldSetMember.getSObjectField());
            }
        }
        
        return fields;
    }

    private List<Schema.FieldSetMember> getFieldSetMembersByAPIName(String fieldSetAPIName) {
        return getSObjectType()
            .getDescribe()
            .FieldSets
            .getMap()
            .get(fieldSetAPIName)
            ?.getFields();
    }

    public Map<SObjectField, String> getFieldSetMap(String fieldSetAPIName){
        Map<SObjectField, String> fieldSetMap = new Map<SObjectField, String>();
        List<Schema.FieldSetMember> fieldSetMembers = getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetAPIName)?.getFields();
        if (fieldSetMembers != null) {
            for (Schema.FieldSetMember fieldSetMember :fieldSetMembers){
                fieldSetMap.put(fieldSetMember.getSobjectField(), fieldSetMember.getFieldPath());
            }
        }

        return fieldSetMap;
    }

    public ApplicationDomain validateRequiredSObjectFields() {
        return validateFields(getRequiredFieldsInfoBySObjectType());
    }

    public virtual ApplicationDomain validateRequiredSObjectFieldsForExternal(EventService.EventServiceWrapper esw) {
        return validateRequiredSObjectFields();
    }

    public ApplicationDomain validateSObjectFieldValues(String recordTypeName) {
        Map<String,SObjectField> sObjectFieldsByName = getSObjectType().getDescribe().fields.getMap();
        for (String sObjectFieldName : sObjectFieldsByName.keySet()) {
            Schema.DisplayType sObjectFieldDataType = getFieldDataType(sObjectFieldName);
            Schema.SObjectField sObjectField = sObjectFieldsByName.get(sObjectFieldName);
            List<SObject> records = getRecordsWithNotBlankFieldValues(sObjectField);
            for (SObject record : records) {
                validateFieldValue(record, recordTypeName, sObjectFieldDataType.name(), sObjectFieldName);
            }
        }
        return this;
    }

    public ApplicationDomain validateSObjectFieldLength() {
        Map<String,SObjectField> sObjectFieldsByName = getSObjectType().getDescribe().fields.getMap();
        for (String sObjectFieldName : sObjectFieldsByName.keySet()) {
            Schema.SObjectField sObjectField = sObjectFieldsByName.get(sObjectFieldName);
            Schema.SoapType sObjectFieldSOAPType = getFieldSOAPType(sObjectFieldName);
            List<SObject> records = getRecordsWithNotBlankFieldValues(sObjectField);
            for (SObject record : records) {
                validateFieldLength(record, sObjectFieldSOAPType.name(), sObjectField, sObjectFieldName);
            }
        }
        return this;
    }

    public ApplicationDomain validateSObjectDuplicationRules() {
        List<String> duplicatedFields = new List<String>();
        Datacloud.FindDuplicatesResult[] findDuplicateResults = Datacloud.FindDuplicates.findDuplicates(this.records);
        for (Datacloud.FindDuplicatesResult findDuplicateResult : findDuplicateResults) {
            for (Datacloud.DuplicateResult duplicateResult : findDuplicateResult.getDuplicateResults()) {
                if(duplicateResult?.getDuplicateRule() != Duplicate_Rule_Setting__mdt.getInstance(duplicateResult?.getDuplicateRule())?.Duplicate_rule_name__c) {
                    for (Datacloud.MatchResult matchResult : duplicateResult.getMatchResults()) {
                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            for (Datacloud.FieldDiff diff : matchRecord.getFieldDiffs()) {
                                if (diff.getDifference() == 'SAME' && !duplicatedFields.contains(diff.getName())) {
                                    duplicatedFields.add(diff.getName());
                                }
                            }
                        }
                    }
                }
            }
        }
        if(!duplicatedFields.isEmpty()) {
            String duplicatedFieldsString = JSON.serialize(duplicatedFields).replaceAll('\\[|]|"','');
            throw new DomainException(String.format(System.Label.DuplicatesFound, new List<String>{duplicatedFieldsString}));
        }
        return this;
    }

    public Map<SObjectField,String> getRequiredFieldsInfoBySObjectType() {
        Map<SObjectField,String> requiredFieldsNameBySObjectField = new Map<SObjectField,String>();
        Map<String,SObjectField> sObjectFieldsByName = getSObjectType().getDescribe().fields.getMap();
        for (String name : sObjectFieldsByName.keySet()) {
            Schema.SObjectField sObjectField = sObjectFieldsByName.get(name);
            Schema.DescribeFieldResult fieldDescribe = sObjectField.getDescribe();
            if (!fieldDescribe.isNillable() && fieldDescribe.isCreateable() && !fieldDescribe.isDefaultedOnCreate()) {
                requiredFieldsNameBySObjectField.put(sObjectField, name);
            }
        }
        return requiredFieldsNameBySObjectField;
    }

    public void validateFieldValue(SObject record, String recordTypeName, String sObjectFieldDataTypeName, String sObjectFieldName) {
        if (sObjectFieldDataTypeName.equalsIgnoreCase(Schema.DisplayType.EMAIL.name())) {
            if (record?.get(sObjectFieldName) != null) {
                String value = String.valueOf(record.get(sObjectFieldName));
                // validateEmail(value); commented out until we get email regex from saleforce
            }
        } else if(sObjectFieldDataTypeName.equalsIgnoreCase(Schema.DisplayType.PICKLIST.name())) {
            if (record?.get(sObjectFieldName) != null) {
                String value = String.valueOf(record.get(sObjectFieldName));
                Map<String,SObjectField> sObjectFieldsByName = getSObjectType().getDescribe().fields.getMap();
                validatePicklistEntry(recordTypeName, value, sObjectFieldsByName.get(sObjectFieldName));
            }
        } 
    }

    public void validateFieldLength(SObject record, String sObjectFieldDataSOAPTypeName, Schema.SObjectField sObjectField, String sObjectFieldName) {
        if(sObjectFieldDataSOAPTypeName.equalsIgnoreCase(Schema.SoapType.INTEGER.name()) || 
            sObjectFieldDataSOAPTypeName.equalsIgnoreCase(Schema.SoapType.DOUBLE.name())) {
                validateNumberFieldLength(record,sObjectField,sObjectFieldName);
        } else if(sObjectFieldDataSOAPTypeName.equalsIgnoreCase(Schema.SoapType.STRING.name()) || 
                sObjectFieldDataSOAPTypeName.equalsIgnoreCase(Schema.SoapType.ID.name())) {
            Integer maxFieldLength = sObjectField.getDescribe().getLength();
            if(record?.get(sObjectFieldName) != null) {
                String value = String.valueOf(record.get(sObjectFieldName));
                if(value.length() > maxFieldLength) {
                    throw new DomainException(String.format(System.Label.InvalidFieldLength, new List<String>{sObjectFieldName, 
                        String.valueOf(maxFieldLength), 
                        String.valueOf(value.length())
                    }));
                }
            }
        }
    }

    public void validateNumberFieldLength(SObject record, Schema.SObjectField sObjectField, String sObjectFieldName) {
        Integer maxAllowedDigitsRight = sObjectField.getDescribe().getScale();
        Integer maxAllowedDigitsLeft = sObjectField.getDescribe().getPrecision() - sObjectField.getDescribe().getScale();
        if(record?.get(sObjectFieldName) != null) {
            Decimal decimalValue = (Decimal)record.get(sObjectFieldName);
            String value = decimalValue.format().remove(',');
            if(value.remove('.').length() > MAX_NUMBER_OF_DIGITS_ALLOWED) {
                throw new DomainException(String.format(System.Label.InvalidFieldLength, new List<String>{sObjectFieldName, 
                    String.valueOf(MAX_NUMBER_OF_DIGITS_ALLOWED), 
                    String.valueOf(value.remove('.').length())
                }));
            }
            List<String> numberParts = value.split('\\.');
            if(numberParts.size() >= 1) {
                if(numberParts[0].length() > maxAllowedDigitsLeft) {
                    throw new DomainException(String.format(System.Label.InvalidFieldLength, new List<String>{sObjectFieldName, 
                        String.valueOf(maxAllowedDigitsLeft), 
                        String.valueOf(numberParts[0].length())
                    }));
                }
                if(numberParts.size() == 2 && numberParts[1].length() > maxAllowedDigitsRight) {
                    throw new DomainException(String.format(System.Label.InvalidDecimalPointFieldLength, new List<String>{sObjectFieldName, 
                        String.valueOf(maxAllowedDigitsRight), 
                        String.valueOf(numberParts[1].length())
                    }));
                }
            }
        }
    }

    public Schema.DisplayType getFieldDataType(String fieldName) {
        return SObjectDescribe.fields
                    .getMap()
                    .get(fieldName)
                    .getDescribe()
                    .getType();
    }
    
    public Schema.SOAPType getFieldSOAPType(String fieldName) {
        return SObjectDescribe.fields
                    .getMap()
                    .get(fieldName)
                    .getDescribe()
                    .getSOAPType();
    }

    protected ApplicationDomain validateFields(Map<SObjectField, String> requiredFieldsToName) {
        Boolean requiredFieldsMissing = !getRecordsWithBlankFieldValues(requiredFieldsToName.keySet()).isEmpty();
        if (requiredFieldsMissing) {
            String requiredFieldsJoinedBySeperator = String.join(requiredFieldsToName.values(),', ');
            String SObjectTypeName = getSObjectType().getDescribe().getName();
            List<String> formattingArguments = new List<String>{requiredFieldsJoinedBySeperator,SObjectTypeName};
            String exceptionMessage = String.format(System.Label.DataPolicyException,formattingArguments);
            throw new DomainException(exceptionMessage);
        }
        return this;
    }

    protected ApplicationDomain validateNonNullableFields(Map<SObjectField, String> requiredFieldsToName) {
        List<SObject> result = validatePayloadFieldsToUpdate(requiredFieldsToName);
        if (!result.isEmpty()) {
            String requiredFieldsJoinedBySeperator = String.join(requiredFieldsToName.values(),', ');
            String SObjectTypeName = getSObjectType().getDescribe().getName();
            List<String> formattingArguments = new List<String>{requiredFieldsJoinedBySeperator,SObjectTypeName};
            String exceptionMessage = String.format(System.Label.DataPolicyExceptionUpdate,formattingArguments);
            throw new DomainException(exceptionMessage);
        }
        return this;
    }

    protected ApplicationDomain validateBlankFieldsAndInteger(Map<SObjectField, String> requiredFieldsToName) {
            Boolean requiredFieldsMissing = !getRecordsWithBlankFieldValuesAndIntegers(requiredFieldsToName.keySet()).isEmpty();
            if (requiredFieldsMissing) {
                String requiredFieldsJoinedBySeperator = String.join(requiredFieldsToName.values(),', ');
                String SObjectTypeName = getSObjectType().getDescribe().getName();
                List<String> formattingArguments = new List<String>{requiredFieldsJoinedBySeperator,SObjectTypeName};
                String exceptionMessage = String.format(System.Label.DataPolicyExceptionInvalidValue,formattingArguments);
                throw new DomainException(exceptionMessage);
            }

        return this;
    }

    /*
     * Method to omit the fields that are not in the payload request, and only check which are present and are blank
     *
     *  @param Map<SObjectField, String> requiredFieldsToName
     *  @Return List<SObject>
     */
    private List<SObject> validatePayloadFieldsToUpdate(Map<SObjectField, String> requiredFieldsToName){
        List<SObject> result = new List<SObject>();
        for (SObject record : getRecords())
        {
            for (SObjectField sObjectField : requiredFieldsToName.keySet()) {
                if (record?.get(sObjectField) != null && String.isBlank(String.valueOf(record?.get(sObjectField)))) {
                    result.add(record);
                    break;
                }
            }
        }
        return result;
    }

    public void validatePicklistEntry(String recordTypeName, String value, SObjectField field) {
        List<String> picklistEntries = getPicklistEntries(field, recordTypeName);
        if (!picklistEntries.contains(value.toLowerCase())) {
            String picklistEntriesJoined = String.join(picklistEntries,', ');
            throw new DomainException(
                String.format(System.Label.InvalidPicklistEntry,new List<String>{
                    value
                    ,field.getDescribe().getName()
                    ,picklistEntriesJoined
            }));
        }
      }
    
    public virtual List<String> getPicklistEntries(SObjectField field, String recordTypeName) {
        Schema.DescribeFieldResult fieldMetadata = field.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldMetadata.getPicklistValues();

        List<String> returnValues = new List<String>();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            returnValues.add(picklistEntry.getValue().toLowerCase());
        }
        return returnValues;
    }

    public void validateEmail(String email) {
        // RFC 5322 Official Standard, obtained from https://emailregex.com/
        String emailRegex = '(?:[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*|"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if (!MyMatcher.matches()) {
            throw new DomainException(String.format(System.Label.InvalidEmailProvided, new List<String>{email}));
        }
    }

    // Code forked from here: https://github.com/apex-enterprise-patterns/fflib-apex-common-samplecode/issues/14
    public String verror(String message, SObject record)    {
        idInErrorMap.put((ID)record.get('ID'),record);
        return error(message, record);  
    }

    public String verror(String message, SObject record, SObjectField field)    {
        idInErrorMap.put((ID)record.get('ID'),record);
        return error(message, record, field);   
    }

    public Boolean hasError(ID id) {
        return idInErrorMap.containsKey(id);
    }

    public SObject[] validRecords() { // exclude from queries records already noted as failing onValidate
        if (idInErrorMap.isEmpty()) return Records; // if no errors in domain instance, avoid looping to find nothing.  
        SObject[] res = new List<SObject>();
        for (SObject sobj : (List<SObject>) Records) {
            ID id = (ID) sobj.get('id');
            if (id == null || !hasError(id)) res.add(sobj);
        }
        return res;
    }

    private Set<Schema.SObjectField> historyTrackingFieldTokens {
        get {
            if (historyTrackingFieldTokens == null ) {
                historyTrackingFieldTokens = new Set<Schema.SObjectField>();
                for (Schema.FieldSetMember fieldSetMember : sObjectType().getDescribe().fieldSets.getMap().get('History_Tracking')?.getFields()) {
                    historyTrackingFieldTokens.add(fieldSetMember.getSObjectField());
                }
            }
            return historyTrackingFieldTokens;
        }
        set;
    }

    public void trackSObjectHistory() {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        for (Schema.SObjectField fieldToken : historyTrackingFieldTokens) {
            for (SObject newRecord : this.Records) {
                String fieldName = fieldToken.getDescribe().getName();
                if (newRecord.get(fieldName) != ExistingRecords.get(newRecord.Id).get(fieldName)) {                        
                    History_Tracking__c historyTrackingRecord = new History_Tracking__c(
                        Field_API_Name__c = fieldName,
                        Record_Id__c = newRecord.Id,
                        Object_Name__c = String.valueOf(sObjectType()),
                        New_Value__c =  String.valueOf(newRecord.get(fieldName)),
                        Old_Value__c = String.valueOf(ExistingRecords.get(newRecord.Id).get(fieldName)),
                        Time_of_Last_Change__c = Datetime.valueOf(newRecord.get('CreatedDate'))
                    );
                    setRelationShipFieldHistoryTrackingAndDomainRecord(historyTrackingRecord, newRecord.Id);
                    unitOfWork.registerNew(historyTrackingRecord);
                }
            }
        }
        unitOfWork.commitWork();
    }

    private void setRelationShipFieldHistoryTrackingAndDomainRecord(History_Tracking__c historyTrackingRecord, Id recordId) {
        for (Schema.ChildRelationship childRelationShip : getSObjectType().getDescribe().getChildRelationships()) {
            if (childRelationShip.getChildSObject().getDescribe().getName() == 'History_Tracking__c') {
                historyTrackingRecord.put(childRelationShip.getField(), recordId);
                break;
            }
        }
    }

}