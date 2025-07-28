public class InvoiceHelper {

    private final Order order;

    public InvoiceHelper(ApexPages.StandardController stdController) {
        this.order = (Order)stdController.getRecord();
    }

    public String getSignatureImageUrl() {
        List<ContentDocumentLink> links = [
                SELECT ContentDocument.LatestPublishedVersion.VersionDataUrl
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :order.Id
                AND ContentDocument.LatestPublishedVersion.Title = 'Signature'
                ORDER BY ContentDocument.CreatedDate DESC
                LIMIT 1
        ];

        System.debug('InvoiceHelper: Found ' + links.size() + ' signature files.');

        if (!links.isEmpty()) {
            System.debug('InvoiceHelper: Signature found! Returning VersionDataUrl:' + links[0].ContentDocument.LatestPublishedVersion.VersionDataUrl);
            return links[0].ContentDocument.LatestPublishedVersion.VersionDataUrl;
        }

        System.debug('InvoiceHelper: No signature found. Returning null.');
        return null;
    }
}