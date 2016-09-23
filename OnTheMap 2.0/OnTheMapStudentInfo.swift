//
//  OnTheMapStudentInfo.swift
//  OnTheMap 2.0
//
//  Created by Xiaochao Luo on 2016-04-15.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation


struct studentInfo {
    
    var firstName: String?
    var lastName: String?
    var latitude: Double!
    var longitude: Double!
    var mapString: String?
    var mediaURL: String?
    var updatedAt: String?
    
    init(dictionary: [String:AnyObject]){
        
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as?Double
        mapString = dictionary["mapString"] as? String
        mediaURL = dictionary["mediaURL"] as? String
        updatedAt = dictionary["updatedAt"] as? String
    }
    
    static func locationsFromResults(_ results: [[String:AnyObject]]) -> [studentInfo]{
        
        var info = [studentInfo]()
        for result in results{
            info.append(studentInfo(dictionary: result))
        }
        return info
    }
    
    
    
    
}
