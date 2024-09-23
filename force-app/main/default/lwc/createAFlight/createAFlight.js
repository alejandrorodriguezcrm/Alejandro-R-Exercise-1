import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveFlight from '@salesforce/apex/CreateAFlightController.saveFlight';

export default class CreateAFlight extends LightningElement {
    @track isLoading = false;
    @track recordId;
    DepartureAirportCode;
    ArrivalAirportCode;


    matchingInfo = {
        primaryField: { fieldPath: 'IATA_Code__c' },
        additionalFields: [{ fieldPath: 'Name' }],
    };

    handleDepartureSelect(event) {
        this.DepartureAirportCode = event.detail.recordId;
    }

    handleArrivalSelect(event) {
        this.ArrivalAirportCode = event.detail.recordId;
    }

    saveFlight() {
        this.isLoading = true;
        saveFlight({ DepartureAirportId: this.DepartureAirportCode, ArrivalAirportId: this.ArrivalAirportCode })
            .then(result => {
                this.recordId = result;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Flight created successfully',
                    variant: 'success',
                }));
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                }));
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
}