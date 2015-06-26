//
//  ListViewController.swift
//  On The Map
//
//  Created by Matthew Dean Furlo on 6/18/15.
//  Copyright (c) 2015 FurloBros. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var locationTableView: UITableView!

    
    
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
    
    //sets the number of rows equal to the length of array containing user location structs
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UdacityClient.sharedInstance().studentInformation.count
    }
    
    // controlls the visible cells containg information on the user name.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "ListTableViewCell"
        let student = UdacityClient.sharedInstance().studentInformation[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        cell.textLabel!.text = student.firstName + " " + student.lastName
        
        
        return cell
    }
    
    //forwards you to safari on a tap, the URL is what was submited by the students
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: UdacityClient.sharedInstance().studentInformation[indexPath.row].mediaURL)!)
    }
    
    //calls the getStudentLocations method then reloads the list
    func reloadData() {
        UdacityClient.sharedInstance().getStudentLocations { (results, error) in
            if let results = results {
                UdacityClient.sharedInstance().studentInformation = results
                dispatch_async(dispatch_get_main_queue()) {
                    self.locationTableView.reloadData()
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
