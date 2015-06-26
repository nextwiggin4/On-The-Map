//
//  UdacityRegisterViewController.swift
//  On The Map
//
//  Created by Matthew Dean Furlo on 6/24/15.
//  Copyright (c) 2015 FurloBros. All rights reserved.
//

import UIKit

class UdacityRegisterViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    let urlRequest: NSURLRequest = NSURLRequest(URL: NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
   
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        
    }
    
    //this brings up a webview and loads the udacity login page
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
            self.webView.loadRequest(urlRequest)
    }
    
    //if login on the website is successful it will bring you to the https://www.udacity.com/me#!/. If you get there it will automatically dismiss the view and bring you back to the loginViewController
    func webViewDidFinishLoad(webView: UIWebView) {
        
        if(webView.request!.URL!.absoluteString! == "https://www.udacity.com/me#!/") {
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //cancle and bring us back to the loginViewController
    @IBAction func cancelReg(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
