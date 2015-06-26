//
//  UdacityClient.swift
//  On The Map
//
//  Created by Matthew Dean Furlo on 6/17/15.
//  Copyright (c) 2015 FurloBros. All rights reserved.
//

import Foundation
import CoreLocation

class UdacityClient : NSObject {
    
    /* Shared session*/
    var session: NSURLSession
    
    /* Authentication state */
    var sessionID: String? = nil
    var userLocation = ParseStudentLocation()
    
    /* array for shared data */
    var studentInformation = [ParseStudentLocation]()
    
    //called when the singleton is created.
    override init(){
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    /* this method sends an email and password string for log in credentials. It stores user info in the singleton for user key. It also calls
    the getUdacityUserInformation for method if it successfuly logs in and stores the information in the singleton. It passes the success or fail to the view controller */
    func authenticateWithUdacity(email: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) -> NSURLSessionTask {
        
        /*  1. Set the parameters */
        
        /* 2. Build the URL */
        
        let urlString = UdacityClient.Constants.UdacityBaseURLSecure + UdacityClient.Methods.Sessions
        let url = NSURL(string: urlString)!
        
        /* configure the request*/
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        //let session = NSURLSession.sharedSession()
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError { // Handle error…
                //let newError = UdacityClient.errorForData(data, response: response, error: downloadError)
                completionHandler(success: false, errorString: "there was a download error")
            } else {
                
                /* parse the data */
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* 6. use the data! */
                if let error = parsingError {
                    completionHandler(success: false, errorString: "there was an error while parsing the data")
                } else {
                    if let account = parsedResult["account"] as? NSDictionary {
                        self.userLocation.uniqueKey = (account["key"] as! String)
                        self.getUdacityUserInformation(self.userLocation.uniqueKey) { (success,error) in
                            if success {
                                completionHandler(success: true, errorString: nil)
                            } else {
                                completionHandler(success: false, errorString: "Failed to get user information")
                            }
                            
                        }
                    } else {
                        completionHandler(success: false, errorString: "no user found")
                    }
                }
                
            }
            
            //println("there was no error")
            
        }
        task.resume()
        
        return task
    }
    
    /* this method takes pulls information form the UdacityClient singleton (using the HTTPBody method) and posts the data to the Parse server*/
    func postStudentLocationToParse(completionHandler: (success: Bool, error: NSError?) -> Void) -> NSURLSessionTask {
        
        println("posting student info")
        
        let urlString = Constants.ParseBaseURLSecure
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        println(self.userLocation.createHTTPBody())
        request.HTTPBody = self.userLocation.createHTTPBody().dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            println("in task")
            println(response)
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                completionHandler(success: true, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    /* this method deletes the token by sending a message to the Udacity servers asking it to logout*/
    func logOutOfUdacity(completionHandler: (success: Bool, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.UdacityBaseURLSecure + Methods.Sessions)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                completionHandler(success: true, error: nil)
            }
        }
        task.resume()
        
        return task
    }
    
    /* this method uses the ID number collected at loging to get the rest of the user information (name). The data is stored in the user struct */
    func getUdacityUserInformation(idNumber: String, completionHandler: (success: Bool, error: NSError?) -> Void) -> NSURLSessionDataTask {
       
        let urlString = UdacityClient.Constants.UdacityBaseURLSecure + UdacityClient.subtituteKeyInMethod(UdacityClient.Methods.UsersData, key: "id", value: idNumber)!
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandler(success: false, error: error)
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            
            if let error = parsingError {
                completionHandler(success: false, error: error)
            } else {
                if let user = parsedResult["user"] as? NSDictionary {
                    self.userLocation.lastName = (user["last_name"] as! String)
                    self.userLocation.firstName = (user["first_name"] as! String)
                    completionHandler(success: true, error: nil)
                } else {
                    completionHandler(success: false, error: error)
                }
            }
            
        }
        task.resume()
        
        return task
    }

    /* this method connects to the parse servers and gathers the last 100 user location objects. If succesful it passes an array of structs in the completeion handler */
    func getStudentLocations(completionHandler: (results: [ParseStudentLocation]?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.ParseBaseURLSecure + "?limit=100"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError { // Handle error…
                println(error.localizedDescription)
                completionHandler(results: nil, error: error)
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let error = parsingError {
                    println("there was a parsing error")
                    completionHandler(results: nil, error: error)
                } else {
                    if let studentInfo = parsedResult["results"] as? [[String: AnyObject]]{
                        var studentInformationArray = ParseStudentLocation.studentLocationFromResults(studentInfo)
                        
                        completionHandler(results: studentInformationArray, error: nil)
                    } else {
                        println("no student info to gather")
                    }
                }
                
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    /* the subsitute method key simply replaces the passed key in the url for the value. */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[UdacityClient.ParseJSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "TMDB Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    /* this method creates a singleton for all other methods to be able to use. Main user data is stored here. */
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}