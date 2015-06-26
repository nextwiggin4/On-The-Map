//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Matthew Dean Furlo on 6/17/15.
//  Copyright (c) 2015 FurloBros. All rights reserved.
//

extension UdacityClient {
    struct Constants {
        
        //Parse API key and App Id strings
        static let ParseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        //URL constants
        static let ParseBaseURLSecure = "https://api.parse.com/1/classes/StudentLocation"
        static let UdacityBaseURLSecure: String = "https://www.udacity.com/api/"
        static let RegistrationURL = "https://www.udacity.com/account/auth#!/signin"
    }
    
    //all URL methods used
    struct Methods {
        static let Sessions = "session"
        static let UsersData = "users/{id}"
    }
    
    //URL Keys used in the subtituteKeyInMethod
    struct URLKeys {
        static let UserID = "id"
    }
    
    //Passed in JSON objects to server
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
    }
    
    //keys used for parsing JSON responses from Parse
    struct ParseJSONResponseKeys {
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
        static let StatusMessage = "status_message"
    }
}

