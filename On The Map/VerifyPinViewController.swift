//
//  VerifyPinViewController.swift
//  On The Map
//
//  Created by Matthew Dean Furlo on 6/23/15.
//  Copyright (c) 2015 FurloBros. All rights reserved.
//

import UIKit
import MapKit

class VerifyPinViewController: UIViewController, MKMapViewDelegate  {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var inputTextField: UITextField!
    
    let regionRadius: CLLocationDistance = 1000
    let locationTextFieldDelegate = locationTextField()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //add the pin for userLocation to the map and zoom in on it.
        self.mapView.addAnnotation(MKPlacemark(placemark: UdacityClient.sharedInstance().userLocation.placemark))
        centerMapOnLocation(UdacityClient.sharedInstance().userLocation.placemark!.location!)
        inputTextField.delegate = self.locationTextFieldDelegate
    }
    
    //this brings us back to the add pin scree. In case you don't like it or something. I don't know why you went back and it's none of my buisness.
    @IBAction func cancelVerifyPin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //call the post method to add the student location to parse. If successful drop back to the mapView.
    @IBAction func submitStudyLocation(sender: AnyObject) {
        UdacityClient.sharedInstance().userLocation.mediaURL = self.inputTextField.text
        UdacityClient.sharedInstance().postStudentLocationToParse() { (success,error) in
            if success {
                self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.throwAlert(error)
            }
        }
    }

    //a helper method to zoom in the map to the location of the pin
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //If there is an error, it will present an alert view with the localized description of the NSError
    func throwAlert (error: NSError?) {
        let alert = UIAlertController(title: "Alert", message: "\(error!.localizedDescription)", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}