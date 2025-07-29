public with sharing class SignatureController {

    @AuraEnabled(Cacheable=true)
    public static Order getOrderDetails(String recordId) {
        return [
                SELECT Id, Status, Signed__c
                FROM Order
                WHERE Id = :recordId
        ];
    }

    @AuraEnabled
    public static void saveSignature(String recordId, String signatureBody) {
        System.debug('SignatureController: saveSignature started');
        String base64Data = signatureBody.substringAfter('base64,');

        try {
            ContentVersion signature = new ContentVersion();
            signature.Title = 'Signature';
            signature.PathOnClient = 'signature.png';
            signature.VersionData = EncodingUtil.base64Decode(base64Data);
            signature.FirstPublishLocationId = recordId;
            insert signature;
            System.debug('SignatureController: Signature file saved. Id: ' + signature.Id);

            Order orderToUpdate = new Order(Id = recordId, Signed__c = true);
            update orderToUpdate;

        } catch (Exception e) {
            System.debug('Exception: ' + e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void generateInvoice(String recordId) {
        Id actualRecordId = (Id) recordId;
        InvoiceGenerator.generateInvoice(new List<Id>{actualRecordId});
    }
}