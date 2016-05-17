//
//  DriverViewController.swift
//  Uber
//
//  Created by Arshin Jain on 4/23/16.
//  Copyright © 2016 Tibbit. All rights reserved.
//

import UIKit
import Parse
import MapKit

class DriverViewController: UITableViewController, CLLocationManagerDelegate {
    
    // Variables
    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    var distances = [CLLocationDistance]()
    
    var locationManager:CLLocationManager!
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        
        latitude = location.latitude
        longitude = location.longitude
        
        
        // Retrieve objects closest to user
        let query = PFQuery(className:"riderRequest")
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
        query.limit = 15 // prevent downloading every object
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                
                // Delete the found objects
                if let objects = objects {
                    
                    self.usernames.removeAll()
                    self.locations.removeAll()
                    
                    for object in objects {
                        
                        
                        if let username = object["username"] as? String {
                            self.usernames.append(username)
                        }
                        
                        if let returnedLocation = object["location"] as? PFGeoPoint {
                            
                            let requestLocation = CLLocationCoordinate2DMake(returnedLocation.latitude, returnedLocation.longitude)
                            self.locations.append( requestLocation )
                            let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                            let driverCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                            
                            let distance = driverCLLocation.distanceFromLocation(requestCLLocation)
                            self.distances.append(distance/1000)
                            
                        }
                        
                        //object.deleteInBackground()
                        self.tableView.reloadData()
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let distanceDouble = Double(distances[indexPath.row])
        
        let roundedDistance = Double( round(distanceDouble * 10) / 10)

        // Configure the cell...
        cell.textLabel?.text = usernames[indexPath.row] + "    " + String(roundedDistance) + " km away"

        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "logoutDriver") {
            
            navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: false)
            
            PFUser.logOut()
            //var currentUser = PFUser.currentUser()
            
        } else if (segue.identifier == "showViewRequests") {
            
            if let destination = segue.destinationViewController as? RequestsViewController {
                
                destination.requestLocation = locations[(tableView.indexPathForSelectedRow?.row)!]
                destination.requestUsername = usernames[(tableView.indexPathForSelectedRow?.row)!]
            }
        }
        
    }

}
