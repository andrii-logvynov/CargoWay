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
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Signature';
            cv.PathOnClient = 'signature.png';
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            insert cv;
            cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

            List<ContentDocumentLink> oldInvoices = [
                    SELECT Id, ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :recordId
                    AND ContentDocument.Title LIKE 'Faktura dla zamówienia%'
            ];
            if (!oldInvoices.isEmpty()) {
                List<ContentDocument> docsToDelete = new List<ContentDocument>();
                for (ContentDocumentLink link : oldInvoices) {
                    docsToDelete.add(new ContentDocument(Id = link.ContentDocumentId));
                }
                delete docsToDelete;
            }
            System.debug('SignatureController: Signature file saved. About to regenerate PDF.');

            InvoiceGenerator.generateInvoice(new List<Id>{recordId});


            Order orderToUpdate = new Order(Id = recordId, Signed__c = true);
            update orderToUpdate;
            System.debug('Pdf updated: ' + orderToUpdate.Id);

        } catch (Exception e) {
            System.debug('Exception: ' + e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}