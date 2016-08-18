//
//  OnTheMapConvenience1.swift
//  OnTheMap 2.0
//
//  Created by Xiaochao Luo on 2016-04-20.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation


extension OnTheMapClient {
    
    func queryForLocation(completionHandlerForQuery:(result: Int!, success: Bool, error: NSError?)->Void){
        
        let parameter = ["where" : "{\"uniqueKey\": \"\(self.account_key!)\"}"]
        let urlString = OnTheMapClient.OnTheMapURLFromParseParameters(parameter)
        
        let request = NSMutableURLRequest(URL: urlString)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForQuery(result: nil, success: false, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                sendError("there is \(error) in queryForLocation")
                return
            }
            
            guard let data = data else{
                sendError("There is no data in Query")
                return
            }
            
            let parsedResults: AnyObject!
            do{
                parsedResults = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }catch {
                sendError("cannot parse the data")
                return
            }
            
            
            if parsedResults != nil {
                let results = parsedResults["results"] as? [[String:AnyObject]]
                
                if results!.count != 0{
                    let updateInfo = results![0]
                    let objectID = updateInfo["objectId"] as? String
                    self.objectID = objectID
                }
                
                completionHandlerForQuery(result: results?.count, success: true, error: error)
            }
            
        }
        task.resume()
    }
    
    func updateLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandlerForUpdate:(success: Bool, error: NSError?)->Void){
        
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(self.objectID!)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(self.account_key!)\", \"firstName\": \"\(self.firstName!)\", \"lastName\": \"\(self.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func sendError(error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForUpdate(success: false, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                sendError("there is \(error) in queryForLocation")
                return
            }
            
            guard let data = data else{
                sendError("There is no data in Query")
                return
            }
            
            let parsedResults: AnyObject!
            do{
                parsedResults = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }catch {
                sendError("cannot parse the data")
                return
            }
            
            completionHandlerForUpdate(success: true, error: error)
            
        }
        task.resume()
        
    }
    
    func loginViaFacebook(accessToken: String, completionHandlerFB:(success: Bool, error: NSError?)-> Void){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken);\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerFB(success: false, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                sendError("there is \(error) in queryForLocation")
                return
            }
            
            guard let data = data else{
                sendError("There is no data in Query")
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            let parsedResults: AnyObject!
            do{
                parsedResults = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            }catch {
                sendError("cannot parse the data")
                return
            }
            
            if let account = parsedResults["account"] as? [String:AnyObject]{
                let account_key = account["key"] as? String
                self.account_key = account_key
                completionHandlerFB(success: true, error: error)
                self.getStudentLocations{(success,result,error) in
                    if success{
                        self.getPublicUserData{(success, lastName,firstName, error) in
                        }
                    }
                }
                
            }
            
        }
        task.resume()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}