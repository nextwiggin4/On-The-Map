//
//  ParseStudentLocation.swift
//  On The Map
//
//  Created by Matthew Dean Furlo on 6/18/15.
//  Copyright (c) 2015 FurloBros. All rights reserved.
//
import CoreLocation

struct ParseStudentLocation {
    
    /* this is all the information needed to interact with the indvidual students on the Parse servers */
    var objectID = ""
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mapString = ""
    var mediaURL = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    //CLGeocoder returns a CLPlacemark. storing a reference makes things easier
    var placemark: CLPlacemark? = nil
    
    /* takes a dictionary fromed parsed JSON and creates a new struct based on it */
    init(dictionary: [String: AnyObject]) {
        objectID = dictionary[UdacityClient.ParseJSONResponseKeys.ObjectID] as! String
        latitude = dictionary[UdacityClient.ParseJSONResponseKeys.Latitude] as! Double
        longitude = dictionary[UdacityClient.ParseJSONResponseKeys.Longitude] as! Double
        uniqueKey = dictionary[UdacityClient.ParseJSONResponseKeys.UniqueKey] as! String
        firstName = dictionary[UdacityClient.ParseJSONResponseKeys.FirstName] as! String
        lastName = dictionary[UdacityClient.ParseJSONResponseKeys.LastName] as! String
        mapString = dictionary[UdacityClient.ParseJSONResponseKeys.MapString] as! String
        mediaURL = dictionary[UdacityClient.ParseJSONResponseKeys.MediaURL] as! String
    }
    
    /* since the student info is stored in this struct, it is necessary to initiate without a dictionary. This is only used by the UdactiyClient for the singleton */
    init() {
        
    }
    
    /* helper function, given an array of dictionaries, this will convert them to an array of ParseStudentLocation objects */
    
    static func studentLocationFromResults(results: [[String: AnyObject]]) -> [ParseStudentLocation] {
        var studentLocations = [ParseStudentLocation]()
        
        for result in results {
            studentLocations.append(ParseStudentLocation(dictionary: result))
        }
        
        return studentLocations
    }
    
    /* returns the JSON string needed to send student inforamtion to the parse servers */
    mutating func createHTTPBody () -> String {
        var HTTPBody = "{\"uniqueKey\": \"\(self.uniqueKey)\", \"firstName\": \"\(self.firstName)\", \"lastName\": \"\(self.lastName)\",\"mapString\": \"\(self.mapString)\", \"mediaURL\": \"\(self.mediaURL)\",\"latitude\": \(self.latitude), \"longitude\": \(self.longitude)}"
        
        return HTTPBody
    }
    
}
 