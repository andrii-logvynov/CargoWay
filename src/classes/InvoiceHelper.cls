public class InvoiceHelper {

    private final Order order;

    public InvoiceHelper(ApexPages.StandardController stdController) {
        this.order = (Order)stdController.getRecord();
    }

    public String getSignatureImageUrl() {
        List<ContentDocumentLink> links = [
                SELECT ContentDocument.LatestPublishedVersion.Id
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :order.Id
                AND ContentDocument.LatestPublishedVersion.Title = 'Signature'
                ORDER BY ContentDocument.CreatedDate DESC
                LIMIT 1
        ];

        System.debug('InvoiceHelper: Found ' + links.size() + ' signature files.');

        if (!links.isEmpty()) {
            String link = Url.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=' + links[0].ContentDocument.LatestPublishedVersion.Id;
            System.debug('InvoiceHelper: Signature found! Returning VersionDataUrl:' + link);
            return link;
        }

        System.debug('InvoiceHelper: No signature found. Returning null.');
        return null;
    }
}