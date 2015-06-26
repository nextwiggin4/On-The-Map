//
//  MapViewController.swift
//  On The Map
//
//  Created by Matthew Dean Furlo on 6/20/15.
//  Copyright (c) 2015 FurloBros. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        /* creates and adds the naviation item needed for the app */
        let green = UIColor(red: 0.294, green: 0.698, blue: 0.247, alpha: 1.0)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutButtonTouchUp")
        self.navigationItem.leftBarButtonItem!.tintColor = green
        let rightReloadButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reloadData")
        let rightAddPinButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "MapPin"), style: UIBarButtonItemStyle.Plain, target: self, action: "addPin")
        rightReloadButton.tintColor = green
        rightAddPinButton.tintColor = green
        self.navigationItem.setRightBarButtonItems([rightReloadButton,rightAddPinButton], animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //reloads the data when the screen appears
        reloadData()
    }
    
    //adds annotations for details
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    //makes anotations clicakble, sends the user to Safari with the link
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }

    // THhis takes teh details from array of struckts and turns them in to annotations. Those annotations are then added to mapView
    func addAnnotationsToMap() {
        
        //this clears any annotations currently on the map before adding after a reload
        self.mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for location in UdacityClient.sharedInstance().studentInformation {
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    //calls the getStudentLocations method then reloads the map
    func reloadData() {
        UdacityClient.sharedInstance().getStudentLocations { (results, error) in
            if let results = results {
                UdacityClient.sharedInstance().studentInformation = results
                dispatch_async(dispatch_get_main_queue()) {
                    self.addAnnotationsToMap()
                }
            } else {
                self.throwAlert(error)
            }
            
        }
    }
    
    //brings up the view controller that allows a student to submit their own study location
    func addPin(){
        var controller:AddPinViewController
        controller = self.storyboard?.instantiateViewControllerWithIdentifier("AddPin") as! AddPinViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    //logs the user out of the app
    func logoutButtonTouchUp() {
        UdacityClient.sharedInstance().logOutOfUdacity() { (success, error) in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.throwAlert(error)
            }
        }
        
    }
    //This takes the localized description fomr an NSError and brings up an alert so the user knows the deal.
    func throwAlert (error: NSError?) {
        let alert = UIAlertController(title: "Alert", message: "\(error!.localizedDescription)", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

