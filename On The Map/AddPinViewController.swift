//
//  AddPinViewController.swift
//  On The Map
//
//  Created by Matthew Dean Furlo on 6/22/15.
//  Copyright (c) 2015 FurloBros. All rights reserved.
//

import UIKit
import CoreLocation

class AddPinViewController: UIViewController  {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    
    let locationTextFieldDelegate = locationTextField()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //adds delegte to text field.
        inputTextField.delegate = self.locationTextFieldDelegate
    }
    
    /* dismisses the view controller if you cancel the action */
    @IBAction func cancelAddPin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* using CLGeocoder to find the the location from a string, updates the userLocation strut and callse the verify view controller */
    @IBAction func findOnTheMap(sender: AnyObject) {
        
        findButton.setTitle("Geocoding...", forState: .Normal)
        findButton.enabled = false
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(inputTextField.text) { (placemark, error) in
            if let error = error {
                self.findButton.setTitle("Find on the map", forState: .Normal)
                self.findButton.enabled = true
                
                //if you can't find the location or time out, an alert letting the user know is thrown.
                let alert = UIAlertController(title: "Alert", message: "\(error.localizedDescription)", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                
                // if it was a success, reset the text field and add the new information to the userLocation struct
                self.findButton.setTitle("Find on the map", forState: .Normal)
                self.findButton.enabled = true
                var placemarker = placemark[0] as! CLPlacemark
                
                UdacityClient.sharedInstance().userLocation.placemark = placemarker
                UdacityClient.sharedInstance().userLocation.mapString = self.inputTextField.text
                UdacityClient.sharedInstance().userLocation.longitude = placemarker.location.coordinate.longitude
                UdacityClient.sharedInstance().userLocation.latitude = placemarker.location.coordinate.latitude
                
                //call the verify pin view controller and present it
                var controller:VerifyPinViewController
                controller = self.storyboard?.instantiateViewControllerWithIdentifier("VerifyPin") as! VerifyPinViewController
                
                self.presentViewController(controller, animated: true, completion: nil)
            }
        
        }
    }
    
}
 