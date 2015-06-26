//
//  LoginViewController.swift
//  On The Map
//
//  Created by Matthew Dean Furlo on 6/2/15.
//  Copyright (c) 2015 FurloBros. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    //initalize all the main fields for the login screenL
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    let usernameTextFieldDelegate = locationTextField()
    let passwordTextFieldDelegate = locationTextField()
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var backgroundGradient: CAGradientLayer? = nil
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    /* Based on student comments, this was added to help with smaller resolution devices */
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        /* Configure the UI */
        self.configureUI()
        
        //these delegates are used to clear the text field and dismiss the keybaord on enter
        self.usernameTextField.delegate = self.usernameTextFieldDelegate
        self.passwordTextField.delegate = self.passwordTextFieldDelegate
        
        self.usernameTextField.text = ""
        self.passwordTextField.text = ""
    }

    /* when the login button is touched, this method checks to make sure that both field are filled. If they are, it trys to log in. If succesful it completes the login */
    @IBAction func loginButtonTouch(sender: AnyObject) {
        if usernameTextField.text.isEmpty {
            debugTextLabel.text = "Username Empty."
        } else if passwordTextField.text.isEmpty {
            debugTextLabel.text = "Password Empty."
        } else {
            debugTextLabel.text = "Logging In"
            UdacityClient.sharedInstance().authenticateWithUdacity(usernameTextField.text, password: passwordTextField.text) { (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(errorString)
                }
            }
        }
    }
    
    /* if the student isn't registered, they can do so in the app by calling this method  */
    @IBAction func registrationButtonTouch(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("RegisterView") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    /* if login is successful this method will pass students on to the main app */
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugTextLabel.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapNavigationController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    /* if there is an erro string, this method will show it to inform the user what they did wrong */
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.debugTextLabel.text = errorString
            }
        })
    }

}

extension LoginViewController {
    
    /* like the color I made it? this is where the magic is done */
    func configureUI() {
        
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 0.0, green: 0.8, blue: 0.2, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient, atIndex: 0)
        
        /* Configure header text label */
        headerTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 24.0)
        headerTextLabel.textColor = UIColor.whiteColor()
        
        /* Configure email textfield */
        let emailTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let emailTextFieldPaddingView = UIView(frame: emailTextFieldPaddingViewFrame)
        usernameTextField.leftView = emailTextFieldPaddingView
        usernameTextField.leftViewMode = .Always
        usernameTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        usernameTextField.backgroundColor = UIColor(red: 0.698, green: 0.8780, blue: 0.760, alpha:1.0)
        usernameTextField.textColor = UIColor(red: 0.0, green:0.6, blue:0.2, alpha: 1.0)
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        usernameTextField.tintColor = UIColor(red: 0.0, green:0.6, blue:0.2, alpha: 1.0)
        
        /* Configure password textfield */
        let passwordTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let passwordTextFieldPaddingView = UIView(frame: passwordTextFieldPaddingViewFrame)
        passwordTextField.leftView = passwordTextFieldPaddingView
        passwordTextField.leftViewMode = .Always
        passwordTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        passwordTextField.backgroundColor = UIColor(red: 0.698, green: 0.8780, blue: 0.760, alpha:1.0)
        passwordTextField.textColor = UIColor(red: 0.0, green:0.6, blue:0.2, alpha: 1.0)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.tintColor = UIColor(red: 0.0, green:0.6, blue:0.2, alpha: 1.0)
        
        /* Configure debug text label */
        headerTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        headerTextLabel.textColor = UIColor.whiteColor()
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
}
