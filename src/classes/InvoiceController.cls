public with sharing class InvoiceController {
    @AuraEnabled
    public static LightningResult downloadInvoice(Id customerTransactionRecordId, String customerId, String transactionId) {
        if (String.isBlank(customerId) || String.isBlank(transactionId)) {
            return LightningResult.addErrorMsg(Label.Missing_Argument);
        }

         return InvoiceService.newInstance().downloadInvoice(customerTransactionRecordId,customerId, transactionId);
    }
}