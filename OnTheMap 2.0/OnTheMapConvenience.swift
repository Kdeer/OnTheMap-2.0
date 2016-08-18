//
//  OnTheMapConvenience.swift
//  OnTheMap 2.0
//
//  Created by Xiaochao Luo on 2016-04-15.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation


extension OnTheMapClient {
    

    func postToLoginSession(username: String, password: String, completionHandlerForLogin: (success: Bool, result: String?, error: NSError?) -> Void){
        
        let parameters = [String:String]()
        let method = OnTheMapClient.Methods.session
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody){(result, error) in
            
            if error != nil {
                print(error)
                completionHandlerForLogin(success: false, result: nil, error: error)
            }else{
                if let account = result["account"] as? [String:AnyObject]{
                    let account_key = account["key"] as! String!
                    self.account_key = account_key
                    completionHandlerForLogin(success: true, result: account_key, error: error)
                    self.getStudentLocations{(success,result,error) in
                    }
                    self.getPublicUserData{(success, lastName,firstName, error) in
                    }
                }else {
                    completionHandlerForLogin(success: false, result: nil, error: NSError(domain: "Parsing Login Data", code: 0, userInfo: [NSLocalizedDescriptionKey: "Canot parse postToLoginSession"]))
                }
            }
        }
    }
    
    func getPublicUserData(completionHandlerForUserData:(success: Bool,lastName: String?,firstName: String?, error: NSError?) -> Void){
        
        let parameters = [String:String]()
        var mutableMethod = OnTheMapClient.Methods.users
        mutableMethod = OnTheMapClient.sharedInstance().subtituteKeyInMethod(mutableMethod, key: "id", value: String(OnTheMapClient.sharedInstance().self.account_key!))!
        
        taskForGETMethod(mutableMethod, parameters: parameters){(result,error) in
            
            if error != nil {
                print(error)
                completionHandlerForUserData(success: false, lastName:nil, firstName: nil, error: error!)
            }else{
                let results = result["user"] as? [String:AnyObject]
                let LastName = results!["last_name"] as? String
                let FirstName = results!["first_name"] as? String
                self.firstName = FirstName
                self.lastName = LastName
                completionHandlerForUserData(success: true, lastName: LastName, firstName: FirstName, error: error)
            }
        }
    }
    
    func getStudentLocations(completionHandlerForLocations:(success: Bool, result: [studentInfo]?, error: NSError?)-> Void){
        
        let parameter: [String:String!] = ["limit" : "50", "order":"-updatedAt"]
        let url = OnTheMapClient.OnTheMapURLFromParseParameters(parameter)
        
        let request = NSMutableURLRequest(URL: url)
        let request1 = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request1.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request1.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request1) { data, response, error in
            
            func sendError(error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForLocations(success: false, result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError("There is an \(error) at getStudentLocations")
                return
            }
            
            guard let data = data else{
                sendError("There is no data at getStudentLocations")
                return
            }
            
            let parsedResults: AnyObject!
            do{
                parsedResults = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }catch {
                sendError("cannot parse the data")
                return
            }
            
            if let result = parsedResults["results"] as? [[String:AnyObject]]{
                print(result)
                let info = studentInfo.locationsFromResults(result)
                self.studentsInfo = info
                completionHandlerForLocations(success: true, result: info, error: error)
            }else{
                sendError("empty parsedResults")
            }
        }
        task.resume()
    }
    
    func postLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandlerForPostLocation:(success: Bool, error: NSError?) -> Void){
        
        let parameter = [String:String]()
        let url = OnTheMapClient.OnTheMapURLFromParseParameters(parameter)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"\(self.account_key!)\", \"firstName\": \"\(self.firstName!)\", \"lastName\": \"\(self.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){(data, response, error) in
            
            
            func sendError(error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForPostLocation(success: false, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError("There is an \(error) at getStudentLocations")
                return
            }
            
            guard let data = data else{
                sendError("There is no data at getStudentLocations")
                return
            }
            
            completionHandlerForPostLocation(success: true, error: error)
            
        }
        
        task.resume()
    }
}