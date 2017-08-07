//
//  DetailsViewController.swift
//  Locations of POI
//
//  Created by Na'Eem Auckburally on 25/11/2016.
//  Name: Na'eem Auckburally
//  ID: 201011641
//  Copyright © 2016 Na'Eem Auckburally. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!              //Outlets for the UI elements
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noPhotoLabel: UILabel!
    @IBOutlet weak var phoneNumLabel: UILabel!
    @IBOutlet weak var numberLink: UITextView!
    @IBOutlet weak var openingTimes: UITextView!
    @IBOutlet weak var websiteTextView: UITextView!

    var placeJsonResult: AnyObject? = nil   //To store the results of the Detailed Places API request
    var selectedPlace: Int?                 //Holds index of place selected in the main view controller, sent in prepare for segue method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("test")
        print(String(selectedPlace!))
        
        getPhoto(flag: false, completionHandler: {(success:Bool) -> Void in})     //Get photo URL and set photo, application waits until photo method is complete
        
        getPlaceID(flag: false, completionHandler: {(success:Bool) -> Void in            //Get the place ID of the selected place
            
            //Get the place name from the json file and assign to the label in the view
            if let place = (((jsonResult?["results"] as? NSArray)?[self.selectedPlace!] as? NSDictionary)?["name"] as? String)
            {
                self.storeNameLabel.text = place
            }
                //Otherwise set the label as unavailable if there was no place name info
            else{
                self.storeNameLabel.text = "Place Name unavailable"
            }
            
            //Get the address from the json file and assign to the label in the view
            if let vicinity = ((self.placeJsonResult?["result"] as? NSDictionary)?["formatted_address"] as? String)
            {
                self.locationLabel.text = vicinity
            }
                //Otherwise set the label as unavailable if there was no location info
            else{
                self.locationLabel.text = "Location unavailable"
            }
            
            //Find if the store is open from the json file and assign to the label in the view
            if let open = ((((jsonResult?["results"] as? NSArray)?[self.selectedPlace!] as? NSDictionary)?["opening_hours"] as? NSDictionary)?["open_now"] as? Bool)
            {
                
                //Check if the boolean is true, if it is assign to open and if it isn't assign to closed
                if(open == true ){
                    self.openLabel.text = "Currently Open"
                } else{
                    self.openLabel.text = "Currently Closed"
                }
            }
                //Otherwise set the label as unavailable if there was no opening info
            else{
                self.openLabel.text = "Information Unavailable"
            }
            
            //Get the rating if there is one from the json file and assign to the label in the view
            if let rating = (((jsonResult?["results"] as? NSArray)?[self.selectedPlace!] as? NSDictionary)?["rating"] as? Double)
            {
                self.ratingLabel.text = "Rating: " + String(rating)
            }
                //Otherwise set the label as unavailable if there was no rating
            else{
                self.ratingLabel.text = "Rating unavailable"
            }
            
            print(self.placeJsonResult)
            
            //Get the phone number if there is one from the json file
            if let phoneNum = ((self.placeJsonResult?["result"] as? NSDictionary)?["formatted_phone_number"] as? String)
            {
                self.numberLink.text = phoneNum //set it too the text field
            }
                //Otherwise set the text field as unavailable if there was no phone number
            else{
                self.numberLink.text = "Phone number unavailable"
            }
            
            //Get the website if there is one from the json file
            if let website = ((self.placeJsonResult?["result"] as? NSDictionary)?["website"] as? String)
            {
                self.websiteTextView.text = website
            }
                //Otherwise set the text field as unavailable if there was no website
            else
            {
                self.websiteTextView.text = "Website unavailable"
            }
            
            //For loop from 0 to 6 for amount of days in a week
            for counter in 0...6 {
                //Get the opening hours string for the current position of the counter in the array
                if let openingTime = ((((self.placeJsonResult?["result"] as? NSDictionary)?["opening_hours"] as? NSDictionary)?["weekday_text"] as? NSArray)?[counter] as? String)
                {
                    print(openingTime)
                    //Add to the text field and add a new line
                    self.openingTimes.text = self.openingTimes.text + "\n" + openingTime
                }
                    //Otherwise if there are no opening times available, set this to the text field
                else{
                    self.openingTimes.text = "Opening times unavailable"
                }
                
                
            }
        })
        //}
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function to retrieve the photo associated with POI if it has one, the application will wait until the photo is returned before continuing
    func getPhoto(flag:Bool, completionHandler:@escaping (_ success:Bool) -> Void) {
        //If the place has a photo, get the photo reference from the json file
        if let photoref = (((((jsonResult?["results"] as? NSArray)?[self.selectedPlace!] as? NSDictionary)?["photos"] as? NSArray)?[0] as? NSDictionary)?["photo_reference"] as? String)
        {
            noPhotoLabel.isHidden = true    //Hide the label, that shows there is no photo available
            
            //Set the url by concactening the reference just retreived with the rest of the url
            let stringURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + photoref + "&key=AIzaSyBlEqo4tTGc88Ry-2dNbwXPbdjUkOZRq4Q"
            
            //Set the url
            let url =  URL(string: stringURL)
            
            DispatchQueue.global().async {
                //Get the data by using the url
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    //Set the image as the image which has just been retrieved from the url
                    self.imageView.image = UIImage(data: data!)
                    completionHandler(true)         //Return that the photo retrieval has completed
                }
            }
        } else
        {
            noPhotoLabel.isHidden = false   //If there is no photo, then show a label which says there is no photo
        }
    }
    
    //When back button is pressed
    @IBAction func backButton(_ sender: AnyObject) {
        performSegue(withIdentifier: "MainView", sender: nil) //Transition back to the main map view
    }
    
    //Getting the place ID from the json and retrieving the place id json with more information, the application will wait until the json is returned before continuing
    func getPlaceID(flag:Bool, completionHandler:@escaping (_ success:Bool) -> Void){
        //Get the placeID from the original json file
        if let placeID = (((jsonResult?["results"] as? NSArray)?[self.selectedPlace!] as? NSDictionary)?["place_id"] as? String)
        {
            print(placeID)
            //Create the new json url using this retrieved place id
            let placeJSONURL = "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + placeID + "&key=AIzaSyBlEqo4tTGc88Ry-2dNbwXPbdjUkOZRq4Q"
            print(placeJSONURL)
            
            //Set the url
            let url = URL(string: placeJSONURL)!
            
            //Retrieve the json file from the web
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error)
                } else {
                    if let urlContent = data {
                        do {
                            //get the json from the url
                            self.placeJsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            DispatchQueue.main.async {
                                completionHandler(true)             //Return that the json retrieval has been completed
                            }
                        } catch {
                            print("======\nJSON processing Failed\n=======")
                        }
                    }
                }
            }
            task.resume()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
