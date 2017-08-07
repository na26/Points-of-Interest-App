//
//  ViewController.swift
//  Locations of POI
//
//  Created by Na'Eem Auckburally on 24/11/2016.
//  Name: Na'eem Auckburally
//  ID: 201011641
//  Copyright © 2016 Na'Eem Auckburally. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

var places = [Dictionary<String, String>()]     //Array of dictionary - holds the information of places of the search
var jsonResult: AnyObject? = nil                //Holds the json file

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    var currentLongitude: Double?                               //("-2.966531") (Backup values for Ashton Building)
    var currentLatitude: Double?                                //("53.406566")
    var routeLongitude: Double?
    var routeLatitude: Double?
    var locationManager: CLLocationManager!                 //Location manager to find users current location
    var currentURL: String? = nil
    var chosenPOI: Int? = nil
    var currentFilter: String? = "store&keyword=supermarket"  //When returning to this controller from the details controller
    var first: Bool = true                                    //Boolean value to check if its the first time loaded
    
    @IBOutlet weak var postcodeField: UITextField!
    @IBOutlet weak var tableOutlet: UITableView!            //Outlets for all the ui elements
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var filterButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterLabel2: UILabel!
    @IBOutlet weak var pcSearchOutlet: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //method for when the view appears
    override func viewDidAppear(_ animated: Bool) {
        if(first == true){
            places.remove(at: 0)                     //removes the first entry of array
            
            tableOutlet.isHidden = true                                     //Hide the table to make the map larger
            map.frame = CGRect(x: 0, y: 96, width: 375, height: 559)        //Set the maps larger size
            
            //Check if location servives is enabled, plist file requests location for user
            if (CLLocationManager.locationServicesEnabled())
            {
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest       //Location manager setup
                locationManager.requestAlwaysAuthorization()                    //To get user's location
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
            }
        }
        
        if(currentFilter == "store&keyword=supermarket")          //Checks the current filter and change the corresponding label
        {
            self.filterLabel2.text = "Supermarkets"
        }
        if(currentFilter == "store&keyword=electronics")          //Checks the current filter and change the corresponding label
        {
            self.filterLabel2.text = "Electronic Stores"
        }
        if(currentFilter == "atm")                               //Checks the current filter and change the corresponding label
        {
            self.filterLabel2.text = "ATM's"
        }
        if(currentFilter == "hospital")                          //Checks the current filter and change the corresponding label
        {
            self.filterLabel2.text = "Hospitals"
        }
        if(currentFilter == "museum")                            //Checks the current filter and change the corresponding label
        {
            self.filterLabel2.text = "Museums"
        }
        if(currentFilter == "hotel")                             //Checks the current filter and change the corresponding label
        {
            self.filterLabel2.text = "Hotels"
        }
        
        //Checks if user  returns from the details view to this map view, and reloads all the map points and the table
        if(first == false){
            addToMap()      //Calling the function add to map
            
            //Set the span and zoom of the map to the place which the user has just clicked on and returned to the map
            let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: Double(places[chosenPOI!]["latitude"]!)!, longitude: Double(places[chosenPOI!]["longitude"]!)!), span: span)
            self.map.setRegion(region, animated: true)
        }
    }
    
    //Function for managing the core location, gets the coordinates of the current location by GPS
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last! as CLLocation        //Gets the last location of the user
        manager.stopUpdatingLocation()
        
        //Using the coordinates to set the map to this location
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
        
        currentLongitude = location.coordinate.longitude        //Set the current coordinates from the current location
        currentLatitude = location.coordinate.latitude
        
        routeLatitude =   location.coordinate.latitude          //Set variable for the route method
        routeLongitude = location.coordinate.longitude
        
        self.map.setRegion(region, animated: true)              //Show on map
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Setting the number of sections in the table to 1
    public func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //Setting the number of rows to the number of places in the dictionary
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }
    
    //Method to fill the table with values
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Getting the cell
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        //Check if there is a value to assign, assign from the places dictionary
        if places[indexPath.row]["name"] != nil {
            if places[indexPath.row]["vicinity"] != nil {
            cell.textLabel?.text = places[indexPath.row]["name"]! + " " + places[indexPath.row]["vicinity"]!    //Add name and location of place to the cell's label
            }
        }
        return cell
    }
    
    //When the user selects an entry from the table
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //currentPlace = indexPath.row    //Set the variable holding the current place to the row that has been selected
        chosenPOI = indexPath.row
        first = false   //assign to boolean to show that the main view has been exited at least once
        performSegue(withIdentifier: "DetailsView", sender: nil)    //transition to the details view    
    }
    
    //Before the view transitions to the details view controller, some data needs to be sent
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableOutlet.indexPathForSelectedRow {           //Check if a row has been selected
            let controller = segue.destination as! DetailsViewController        //Get the index and send to the variable in the details view controller
            controller.selectedPlace = indexPath.row
        }
    }
    
    //When the search button is pressed
    @IBAction func searchButton(_ sender: AnyObject) {
        currentLatitude = map.centerCoordinate.latitude                     //Get location of the centre of the map currently
        currentLongitude = map.centerCoordinate.longitude                   //So the nearby POI's to this point can be found
        tableOutlet.isHidden = false                                        //Re show the table that was previously hidden
        map.frame = CGRect(x: 0, y: 96, width: 375, height: 248)            //Make the map smaller to fit all UI elements on screen together
        searchPOI()                                                         //Call the search function

    }
    
    //When the current location button is pressed
    @IBAction func currentLocationButton(_ sender: AnyObject) {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()                           //Get the users current location and call method which sets this to the map
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest       //Setting up location manager
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    //Method to retrieve the json file from the google API, application waits until json is returned
    func getJSON(flag:Bool, completionHandler:@escaping (_ success:Bool) -> Void){
        //Set up the url and task
        let url = URL(string: currentURL!)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error)
            } else {
                if let urlContent = data {
                    do {
                        jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        DispatchQueue.main.async {
                            completionHandler(true)                     //Return that the json result retrieval was completed
                        }
                    } catch {
                        print("======\nJSON processing Failed\n=======")
                        //Add in a UI alert here possibly
                    }
                }
            }
        }

        task.resume()
    }
    
    //Filter button handling, when the filter button is clicked
    @IBAction func filterButton(_ sender: AnyObject) {
        //Setup an alert controller which will display options for the user to select their filter
        let alertController = UIAlertController(title: nil, message: "Filter", preferredStyle: .actionSheet)    //Add cancel option to alert controller
        
        //Add a cancel button to dismiss the alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let supermarketOption = UIAlertAction(title: "Supermarkets", style: .default) { (action) in     //Add supermarket option to alert controller
            // ...
            DispatchQueue.main.async {
                self.currentFilter = "store&keyword=supermarket"                                        //Change the corresponding variable(s) for the filter
                self.filterLabel2.text = "Supermarkets"                                                 //Change the label based on the chosen filter
            }
        }
        alertController.addAction(supermarketOption)
        
        let electronicOption = UIAlertAction(title: "Electronic Stores", style: .default) { (action) in     //Add electronic option to alert controller
            // ...
            DispatchQueue.main.async {
                self.currentFilter = "store&keyword=electronics"                                            //Change the corresponding variable(s) for the filter
                self.filterLabel2.text = "Electronic Stores"                                                //Change the label based on the chosen filter
            }
        }
        alertController.addAction(electronicOption)
        
        let atmOption = UIAlertAction(title: "ATM's", style: .default) { (action) in        //Add ATM option to alert controller
            DispatchQueue.main.async {
                self.currentFilter = "atm"                                                  //Change the corresponding variable(s) for the filter
                self.filterLabel2.text = "ATM's"                                            //Change the label based on the chosen filter
            }
        }
        alertController.addAction(atmOption)
        
        let hospitalOption = UIAlertAction(title: "Hospitals", style: .default) { (action) in   //Add hospital option to alert controller
            DispatchQueue.main.async {
                self.currentFilter = "hospital"                                                 //Change the corresponding variable(s) for the filter
                self.filterLabel2.text = "Hospitals"                                            //Change the label based on the chosen filter
            }
        }
        alertController.addAction(hospitalOption)
        
        let museumOption = UIAlertAction(title: "Museums", style: .default) { (action) in   //Add museum option to alert controller
            DispatchQueue.main.async {
                self.currentFilter = "museum"                                               //Change the corresponding variable(s) for the filter
                self.filterLabel2.text = "Museums"                                          //Change the label based on the chosen filter
            }
        }
        alertController.addAction(museumOption)
        
        let hotelOption = UIAlertAction(title: "Hotels", style: .default) { (action) in     //Add hotel option to alert controller
            DispatchQueue.main.async {
                self.currentFilter = "hotel"                                                //Change the corresponding variable(s) for the filter
                self.filterLabel2.text = "Hotels"                                           //Change the label based on the chosen filter
            }
        }
        alertController.addAction(hotelOption)
        
        let restaurantOption = UIAlertAction(title: "Restaurants", style: .default) { (action) in   //Add restaurant option to alert controller
            DispatchQueue.main.async {
                self.currentFilter = "restaurant"                       //Change the corresponding variable(s) for the filter
                self.filterLabel2.text = "Restaurants"                 //Change the label based on the chosen filter
            }
        }
        alertController.addAction(restaurantOption)
        
        self.present(alertController, animated: true) {}         //Show the alert controller
        
    }
    
    //Function to set the url of the json file
    func setJson(){
        print(String(describing: currentLatitude!))             //Testing
        print(String(describing: currentLongitude!))
        //The url of the json is set, by concatenating variables which could change such as longitude, latitude and poi filter type
            var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + String(describing: currentLatitude!)
            url = url + "," + String(describing: currentLongitude!) + "&radius=1000&type=" + currentFilter!
            url = url + "&key=AIzaSyBlEqo4tTGc88Ry-2dNbwXPbdjUkOZRq4Q"
            currentURL = url    //set the url
            print("url is")
            print(currentURL)           //testing url


    }

    //Function which adds the annotations to the map using the places array
    func addToMap()
    {
        if let result = (jsonResult?["results"] as? NSArray){
            //Counter in a for loop from 0 to the number of places
            for counter in 0...result.count - 1 {
                //getting the name, longitude and latitude from the places dictionary
                if let name = places[counter]["name"] {
                    if let lat = places[counter]["latitude"] {
                        if let lon = places[counter]["longitude"] {
                            //then set all the relevant info to create and add an annotation to the map.
                            if let latitude = Double(lat) {
                                if let longitude = Double(lon) {
                                    let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.currentLatitude!, longitude: self.currentLongitude!), span: span)
                                    self.map.setRegion(region, animated: true)
                                    let annotation = MKPointAnnotation()
                                    annotation.coordinate = coordinate
                                    
                                    //Calculation of distance from current location to each POI
                                    let radius = 6371   //set radius of earth
                                    
                                    //Calculations to work out distance using trigonometry, using the longs and lats of the 2 points
                                    let dLat = self.degreesToRadians(degrees: latitude - self.currentLatitude!)
                                    let dLong = self.degreesToRadians(degrees: longitude - self.currentLongitude!)
                                    let a = sin(dLat/2) * sin(dLat/2) + cos(self.degreesToRadians(degrees: latitude)) * sin(dLong/2) * sin(dLong/2)
                                    let b = 2 * atan2(sqrt(a), sqrt(1-a))
                                    let distance = (Double(radius) * b) * 0.62137
                                    
                                    //Add name of POI and the distance calculate to the annotation title, format the value to 2 decimal places
                                    annotation.title = name + " (" + String(format: "%.2f", distance) + " miles)"
                                    //Add the annotation to the map
                                    self.map.addAnnotation(annotation)
                                } }
                        } }
                }
                
            }
            
        }
        self.tableOutlet.reloadData()       //Reload the data in the table
    }
    
    //Function for when the postcode button search is pressed, to navigate the map to the postcode
    @IBAction func postcodeButton(_ sender: AnyObject) {
        self.view.endEditing(true)          //Hide the software keyboard
        self.timeLabel.text = ""
        //Check if the text field is empty
        if (postcodeField.text! == "")
        {
            //Set up alert controller with title, message and style
            let alert = UIAlertController(title: "Error", message: "Enter a postcode, don't leave field blank", preferredStyle: UIAlertControllerStyle.alert)
            //Add action to controller
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            //Show the alert controller
            self.present(alert, animated: true, completion: nil)
        }
        else{
            
            let overlays = map.overlays     //Get all overlays
            map.removeOverlays(overlays)    //Remove all overlays
            let allAnnotations = self.map.annotations   //remove all annotations from the map
            self.map.removeAnnotations(allAnnotations)
            
            let address = postcodeField.text!       //sets the address as the entered postcode
            let geocoder = CLGeocoder()             //new geocoder
            
            geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    print("Error", error)
                }
                if let placemark = placemarks?.first {
                    //get the coordinates of the entered postcode
                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                    //get the longitude and latitude
                    self.currentLongitude = coordinates.longitude   //move out of if statement
                    self.currentLatitude = coordinates.latitude
                    
                    print(self.currentLatitude)
                    print(self.currentLongitude)
                    
                    //Set the location and setup annotation to add to the map
                    let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                    let region = MKCoordinateRegion(center: coordinates, span: span)
                    self.map.setRegion(region, animated: true)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinates
                    annotation.title = address
                    self.map.addAnnotation(annotation)
                }
                
            })
        }
    }
   
 
    //Function which carries out the search for places of interest
    func searchPOI() {
        setJson()     //Call the method which sets the json url
        getJSON(flag: false, completionHandler: {(success:Bool) -> Void in     //Call the method which retrieves the json from the Google API
            
            //Delay the code for 1.5 seconds to allow the json URL request to complete
            //delayWithSeconds(1.2) {
            let overlays = self.map.overlays     //Get all overlays
            self.map.removeOverlays(overlays)    //Remove all overlays
            self.timeLabel.text = ""
            print(jsonResult)
            //Check if the json was retrieved or not
            if(jsonResult == nil){
                //If it wasn't retreived, show the user an error message
                let alert = UIAlertController(title: "Error", message: "Information couldn't be retrieved, please try again", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
                places.removeAll()              //remove all entries from places
                let allAnnotations = self.map.annotations   //remove all annotations from the map
                self.map.removeAnnotations(allAnnotations)
                
                //Get the result array from the json file
                if let result = (jsonResult?["results"] as? NSArray){
                    var vicinity: String = ""
                    var searchLatitude: Double!     //variables to store the details of each place
                    var searchLongitude: Double!
                    var place: String = ""
                    
                    //If the json contained no results, show the user an error message showing there are no POI's
                    if result.count == 0{
                        let alert = UIAlertController(title: "No Results", message: "No points of interest could be found, change location or filter", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        
                        //Set up a loop from 0 to the amount of results in the json's array
                        for counter in 0...result.count - 1 {
                            
                            //get the place name from the json file
                            place = (((jsonResult?["results"] as? NSArray)?[counter] as? NSDictionary)?["name"] as? String)!
                            
                            //get the location from the json file
                            vicinity = (((jsonResult?["results"] as? NSArray)?[counter] as? NSDictionary)?["vicinity"] as? String)!
                            
                            //get the latitude from the json file
                            searchLatitude = (((((jsonResult?["results"] as? NSArray)?[counter] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as? NSDictionary)?["lat"] as? NSNumber)! as Double!
                            
                            //get the longitude from the json file
                            searchLongitude = (((((jsonResult?["results"] as? NSArray)?[counter] as? NSDictionary)?["geometry"] as? NSDictionary)?["location"] as? NSDictionary)?["lng"] as? NSNumber)! as Double!
                            
                            //add the details which have been retrieved to the places dictionary
                            places.append(["name": place, "vicinity": vicinity, "latitude": String(searchLatitude), "longitude": String(searchLongitude)])
                            
                        }
                        
                        self.addToMap()         //Call the function to add the places to the map
                    }
                    
                }
                self.tableOutlet.reloadData()       //Reload the data in the table
            }
        })
        
    }
    
    //Helper function for when calculating the distance, covertes input value from degrees to radians
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    
    //Function for finding and displaying a route between the users current location and a selected POI
    func route(inputLatitude: Double, inputLongitude: Double, transportType: MKDirectionsTransportType) {
        //The method will find the route from the centre of the map, to the chosen location
        
        //Route from centre of map
        currentLatitude = map.centerCoordinate.latitude         //Get location of the centre of the map currently
        currentLongitude = map.centerCoordinate.longitude       //So the route can be found from here
        
        //Removing any overlays that are currently on the map, so that the new overlay can be drawn.
        let overlays = map.overlays     //Get all overlays
        map.removeOverlays(overlays)    //Remove all overlays
        
        //Create a request
        let request = MKDirectionsRequest()
        
        //Set the source of directions as the current location's long and lat
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: routeLatitude!, longitude: routeLongitude!), addressDictionary: nil))
        //Set the source of directions as the selected POI location's long and lat
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: inputLatitude, longitude: inputLongitude), addressDictionary: nil))
        //Have one route
        request.requestsAlternateRoutes = false
        //Set the transport type based on the paramater entered, chosen by the user through an alert controller
        request.transportType = transportType
        
        
        //Calulate the directions
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            //Call the add route for the map
            for route in unwrappedResponse.routes {
                //Add the route to the map
                self.map.add(route.polyline)
                self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                //Get the expected time of the route and convert to minutes and assign to label, with 0 decimal places
                print(route.expectedTravelTime)
                self.timeLabel.text = "ETA:             " + String(format: "%.0f", route.expectedTravelTime / 60) + " minutes"
                
                
            }
   
        }
    }
    
    //Function for adding the overlay of the map for the route
    func mapView(_ map: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)     //New renderer for line
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.fillColor = UIColor.blue                       //Setting the appearance of line
        polylineRenderer.lineWidth = 2
        return polylineRenderer                                         //Return line
    }
    

    //Allow the table to be editable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    //Function which handles the table view editing actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //Setup a action sheet alert controller for the user to choose a type of transport
        let typeController = UIAlertController(title: nil, message: "Transport Type", preferredStyle: .actionSheet)
        //Setup a new alert controller with 2 options
        let walkingOption = UIAlertAction(title: "Walking", style: .default) { (action) in     //Add walking option to alert controller
            //Call the route function with the location and walking option for the transport type
            print("test walking")
            self.route(inputLatitude: Double(places[indexPath.row]["latitude"]!)!, inputLongitude: Double(places[indexPath.row]["longitude"]!)!, transportType: .walking)
        }
        typeController.addAction(walkingOption)    //Add to the controller
        
        let drivingOption = UIAlertAction(title: "Driving", style: .default) { (action) in     //Add driving option to alert controller
            //Call the route function with the location and driving option for the transport type
            self.route(inputLatitude: Double(places[indexPath.row]["latitude"]!)!, inputLongitude: Double(places[indexPath.row]["longitude"]!)!, transportType: .automobile)
        }
        typeController.addAction(drivingOption)    //Add to the controller
        //Add a cancel button to dismiss the alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        typeController.addAction(cancelAction)
        
        //Setup a action sheet alert controller for the user to choose the source of the route
        let optionController =  UIAlertController(title: nil, message: "Route Source", preferredStyle: .actionSheet)
        
        let centreOption = UIAlertAction(title: "Centre of Map", style: .default) { (action) in     //Add walking option to alert controller
            //Call the route function with the location and walking option for the transport type
            self.routeLatitude = self.map.centerCoordinate.latitude
            self.routeLongitude = self.map.centerCoordinate.longitude
            self.present(typeController, animated: true) {         //Show the alert controller for the transport type
                // ...
            }
        }
        optionController.addAction(centreOption)    //Add to the controller
        
        let currentOption = UIAlertAction(title: "Current GPS Location", style: .default) { (action) in     //Add walking option to alert controller
            //Call the route function with the location and walking option for the transport type
            self.present(typeController, animated: true) {         //Show the alert controller for the transport type
                // ...
            }
        }
        optionController.addAction(currentOption)    //Add to the controller
        optionController.addAction(cancelAction)
        
        //Where the table is swiped, one button named route is revealed
        //Create a new action, a button which appears when the entry of the table is swiped
        let routeBtn = UITableViewRowAction(style: .normal, title: "Route") { action, index in
            print("route button tapped")
            print(self.routeLatitude)                   //testing
            print(self.routeLongitude)
            self.present(optionController, animated: true){}          //Show the alert controller for the 2 route source options
            
        }
        routeBtn.backgroundColor = UIColor.blue     //Set appearance of the button
        return [routeBtn]
    }

    //When the map type button is pressed, 3 options are shown for the user to change the appearance of the map
    @IBAction func mapTypeButton(_ sender: AnyObject) {
        let typeController = UIAlertController(title: nil, message: "Map Type", preferredStyle: .actionSheet)    //Create new alert controller with name and action sheet style
        
        //Add a cancel button to dismiss the alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        typeController.addAction(cancelAction)
        
        //Add a standard button to change to standard map type
        let standardOption = UIAlertAction(title: "Standard", style: .default) { (action) in     //Add standard option to alert controller
            self.map.mapType = .standard
        }
        typeController.addAction(standardOption)
        
        //Add a satellite button to change to satellite map type
        let satelliteOption = UIAlertAction(title: "Satellite", style: .default) { (action) in     //Add satellite option to alert controller
            self.map.mapType = .satellite
        }
        typeController.addAction(satelliteOption)

        //Add a hybrid button to change to hybrid map type
        let hybridOption = UIAlertAction(title: "Hybrid", style: .default) { (action) in     //Add hybrid option to alert controller
            self.map.mapType = .hybrid
        }
        typeController.addAction(hybridOption)
        
        self.present(typeController, animated: true){}              //Show the alert controller
        
        
    }
    
    
}

