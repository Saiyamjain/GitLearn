public with sharing class CaseActionsController {

    @AuraEnabled
    public static LightningResult getTypeOptionsForMasterOption(ContactUsOptionService.TypeOptionWrapper typeOptionWrapperInstance) {
        if (typeOptionWrapperInstance.contactUsOption == null) {
            return LightningResult.addErrorMsg(Label.Missing_Argument);
        }
        return LightningResult.setResult(ContactUsOptionService.newInstance().getContactUsOptions(typeOptionWrapperInstance.masterOptionValue, typeOptionWrapperInstance.contactUsOption));
    }

    @AuraEnabled
    public static LightningResult getTypeOptions(ContactUsOptionService.TypeOptionWrapper typeOptionWrapperInstance) {
        if (typeOptionWrapperInstance == null || String.isBlank(typeOptionWrapperInstance.caseId)) {
            return LightningResult.addErrorMsg(Label.Missing_Argument);
        }
        try {
            LightningResult.setResult(ContactUsOptionService.newInstance().getContactUsOptions(typeOptionWrapperInstance.caseId));
        } catch(Exception e) {
            LightningResult.setError(e);
        }
        return LightningResult.getInstance();
    }

    @AuraEnabled
    public static LightningResult performCaseActions(CaseService.CaseActionWrapper caw) {
        if (String.isBlank(caw.caseId) || String.isBlank(caw.caseAction) || String.isBlank(caw.caseActionReason) || caw.caseActionType == null) {
            return LightningResult.addErrorMsg(Label.Missing_Argument);
        }
        try {
            CaseService.newInstance().performCaseActions(caw);
        } catch(Exception e) {
            LightningResult.setError(e);
        }
        return LightningResult.getInstance();
    }
}