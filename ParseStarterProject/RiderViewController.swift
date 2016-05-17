//
//  RiderViewController.swift
//  Uber
//
//  Created by Arshin Jain on 4/23/16.
//  Copyright © 2016 Tibbit. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // Outlets
    @IBOutlet var map: MKMapView!
    @IBOutlet var callUberButton: UIButton!
    
    var riderRequestActive = false
    var locationManager:CLLocationManager!
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0
    
    // MARK: - Buttons
    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false {
        
        let riderRequest = PFObject(className:"riderRequest")
        riderRequest["username"] = PFUser.currentUser()?.username
        if (latitude != 0 && longitude != 0) {
            riderRequest["location"] = PFGeoPoint(latitude:latitude, longitude:longitude)
        }
        
        // Saving in background
        riderRequest.saveInBackgroundWithBlock {
            
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                self.callUberButton.setTitle("Cancel Uber", forState: UIControlState.Normal)
                
            } else {
                
                let alert = UIAlertController(title: "Could not call Uber!", message: "Please Try Again!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
            riderRequestActive = true
            
        } else {
            
            riderRequestActive = false
            self.callUberButton.setTitle("Call an Uber", forState: UIControlState.Normal)

            
            // Retrieve objects
            let query = PFQuery(className:"riderRequest")
            query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
            
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    print("Successfully retrieved \(objects!.count) scores.")
                    
                    // Delete the found objects
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
            // ends query
            
        }
        
    }
    
    // MARK: - View & Location
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        
        latitude = location.latitude
        longitude = location.longitude
        
        print("locations = \(location.latitude) \(location.longitude)")
        
        // Zoom to current loc
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        // Remove excessive pins
        self.map.removeAnnotations(map.annotations)
        
        // Display loc using Pin
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "Current Location"
        self.map.addAnnotation(objectAnnotation)
    }
    
    // MARK: - Navigation

    // Whenever Segue happens from this view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "logoutRider") {
            PFUser.logOut()
            //var currentUser = PFUser.currentUser()
        }
        
    }
    

}
