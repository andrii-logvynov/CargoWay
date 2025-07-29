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
    public static String saveSignature(String recordId, String signatureBody) {
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
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :signature.Id].ContentDocumentId;

            ContentDocumentLink signatureLink = [
                    SELECT Id
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :recordId
                    AND ContentDocumentId = :contentDocumentId
            ];

            System.debug('SignatureController: Signature link saved. Id: ' + signatureLink.Id);

            Order orderToUpdate = new Order(Id = recordId, Signed__c = true);
            update orderToUpdate;

            System.debug('signature Id: ' + signature.Id);
            return (String) signature.Id;

        } catch (Exception e) {
            System.debug('Exception: ' + e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void generateInvoice(String recordId) {
        Id actualRecordId = (Id) recordId;
        List<Id> orderIds = new List<Id>{actualRecordId};
        InvoiceGenerator.generateInvoice(orderIds);
    }
}