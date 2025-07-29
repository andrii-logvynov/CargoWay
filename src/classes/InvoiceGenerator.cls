public with sharing class InvoiceGenerator {
    @InvocableMethod(
            Label='Generate Invoice PDF'
            Description='Creates a PDF invoice from an Order record.'
    )
    public static void generateInvoice(List<Id> orderIds) {
        System.debug('Starting invoice generation');
        Id orderId = orderIds[0];
        System.debug('Order Id: ' + orderId);
        PageReference pdfPage = Page.InvoiceTemplate;

        pdfPage.getParameters().put('id', orderId);

        Blob pdfBlob;
        try {
            pdfBlob = pdfPage.getContentAsPDF();
        } catch (Exception e) {
            System.debug('Failed to generate PDF: ' + e.getMessage());
            return;
        }

        ContentVersion invoice = new ContentVersion();
        invoice.Title = 'Faktura dla zamówienia ' + orderId;
        invoice.PathOnClient = 'Faktura.pdf';
        invoice.VersionData = pdfBlob;
        invoice.IsMajorVersion = true;
        insert invoice;

        System.debug('Generated Invoice: ' + invoice.Id);

        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :invoice.Id].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = docId;
        cdl.LinkedEntityId = orderId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }
}