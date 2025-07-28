public with sharing class InvoiceGenerator {
    @InvocableMethod(
            Label='Generate Invoice PDF'
            Description='Creates a PDF invoice from an Order record.'
    )
    public static void generateInvoice(List<Id> orderIds) {
        Id orderId = orderIds[0];

        PageReference pdfPage = Page.InvoiceTemplate;

        pdfPage.getParameters().put('id', orderId);

        Blob pdfBlob;
        try {
            pdfBlob = pdfPage.getContentAsPDF();
        } catch (Exception e) {
            System.debug('Failed to generate PDF: ' + e.getMessage());
            return;
        }

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Faktura dla zamówienia ' + orderId;
        cv.PathOnClient = 'Faktura.pdf';
        cv.VersionData = pdfBlob;
        cv.IsMajorVersion = true;
        insert cv;

        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = docId;
        cdl.LinkedEntityId = orderId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }
}