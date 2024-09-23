public with sharing class CreateAFlightController {

    @AuraEnabled
    public static String saveFlight(String DepartureAirportId, String ArrivalAirportId) {
        try {
            List<Airports__c> airports = [SELECT Location__c FROM Airports__c WHERE Id IN :new List<Id>{DepartureAirportId, ArrivalAirportId} WITH USER_MODE];

            //Order of the airports is not important, as we are calculating the distance between them
            Location DepartureLocation = airports[0].Location__c;
            Location ArrivalLocation = airports[1].Location__c;

            // Calculate the distance between the two airports in meters
            Decimal distanceInMeters = calculateDistance(DepartureLocation.latitude, DepartureLocation.longitude, ArrivalLocation.latitude, ArrivalLocation.longitude);
            //Should be converted to km, as per Excersice requirement
            Decimal distanceInKm = distanceInMeters / 1000;

            Flight__c newFlight = new Flight__c();
            newFlight.Departure_Airport__c = DepartureAirportId;
            newFlight.Arrival_Airport__c = ArrivalAirportId;
            newFlight.Flight_Distance__c = distanceInKm;
            insert AS USER newFlight;
            return newFlight.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    /**
     * @description Method to calculate the distance between two locations using the Haversine formula
     * @param latitude1 - Latitude of the first location
     * @param longitude1 - Longitude of the first location
     * @param latitude2 - Latitude of the second location
     * @param longitude2 - Longitude of the second location
     * @return Distance between the two locations in meters
     */
    private static Decimal calculateDistance(Decimal latitude1, Decimal longitude1, Decimal latitude2, Decimal longitude2) {
        Integer earthRadius = 6371 * 1000; 
        Decimal latitudeRadians1 = latitude1 * Math.PI/180;
        Decimal latitudeRadians2 = latitude2 * Math.PI/180;
        // Latitude and longitude differences in radians
        Decimal latitudeDelta = (latitude2 - latitude1) * Math.PI/180;
        Decimal longitudeDelta = (longitude2 - longitude1) * Math.PI/180;
        Decimal a = Math.sin(latitudeDelta/2) * Math.sin(latitudeDelta/2) + Math.cos(latitudeRadians1) * Math.cos(latitudeRadians2) * Math.sin(longitudeDelta/2) * Math.sin(longitudeDelta/2);
        Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        Decimal distance = earthRadius * arc; // in metres
        return distance;
    }
}