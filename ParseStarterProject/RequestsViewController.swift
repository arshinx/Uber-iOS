//
//  RequestsViewController.swift
//  Uber
//
//  Created by Arshin Jain on 4/23/16.
//  Copyright © 2016 Tibbit. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RequestsViewController: UIViewController, CLLocationManagerDelegate {
    
    // Outlets
    @IBOutlet var map: MKMapView!
    
    @IBAction func pickupRider(sender: AnyObject) {
        
        
        // Retrieve objects
        let query = PFQuery(className:"riderRequest")
        query.whereKey("username", equalTo: requestUsername)
        
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                
                
                // Delete the found objects
                if let objects = objects {
                    
                    for object in objects {
                        
                        object["driverResponded"] = PFUser.currentUser()?.username!
                        
                        object.save() // error?
                        
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        } // ends query
        
        
    }
    
    var requestLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var requestUsername: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(requestUsername)
        print(requestLocation)
        
        // Zoom to current loc
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        // Display loc using Pin
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = requestLocation
        objectAnnotation.title = requestUsername
        self.map.addAnnotation(objectAnnotation)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
