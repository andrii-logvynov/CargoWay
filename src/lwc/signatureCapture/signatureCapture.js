import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import SignaturePad from '@salesforce/resourceUrl/signature_pad';
import saveSignature from '@salesforce/apex/SignatureController.saveSignature';
import getOrderDetails from '@salesforce/apex/SignatureController.getOrderDetails';
import generateInvoice from '@salesforce/apex/SignatureController.generateInvoice';


export default class SignatureCapture extends LightningElement {
    @api recordId;
    isModalOpen = false;

    signaturePad;
    signaturePadInitialized = false;

    order;

    @wire(getOrderDetails, { recordId: '$recordId' })
    wiredOrder({ error, data }) {
        if (data) {
            console.log('data', data);
            this.order = data;
        } else if (error) {
            console.error('Error fetching order details', error);
        }
    }

    get showSignButton() {
        if (this.order) {
            console.log(`${JSON.stringify(this.order)} && ${this.order.Status === 'Active'} && ${!this.order.Signed__c}`)
            return this.order && this.order.Status === 'Active' && !this.order.Signed__c;
        } else {
            return false;
        }
    }

    renderedCallback() {
        if (this.isModalOpen && !this.signaturePadInitialized) {
            this.signaturePadInitialized = true;

            loadScript(this, SignaturePad)
                .then(() => {
                    const canvas = this.template.querySelector('canvas');
                    this.signaturePad = new window.SignaturePad(canvas);
                })
                .catch(error => {
                    this.showToast('Error', 'Could not load signature pad library', 'error');
                });
        }
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.signaturePadInitialized = false;
    }

    handleClearClick() {
        this.signaturePad.clear();
    }

    handleSaveClick() {
        if (this.signaturePad.isEmpty()) {
            this.showToast('Error', 'Please provide a signature.', 'error');
            return;
        }

        const signatureCanvas = this.template.querySelector('canvas');

        const newCanvas = document.createElement('canvas');
        newCanvas.width = signatureCanvas.width;
        newCanvas.height = signatureCanvas.height;
        const ctx = newCanvas.getContext('2d');

        ctx.fillStyle = '#FFFFFF';
        ctx.fillRect(0, 0, newCanvas.width, newCanvas.height);

        ctx.drawImage(signatureCanvas, 0, 0);

        const signatureData = newCanvas.toDataURL('image/png');

        saveSignature({ recordId: this.recordId, signatureBody: signatureData })
            .then(() => {
                generateInvoice({ recordId: [this.recordId] });
            })
            .then(() => {
                this.showToast('Success', 'Signature saved successfully.', 'success');
                this.closeModal();
                window.location.reload();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
    }
}