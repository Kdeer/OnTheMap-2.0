//
//  OnTheMapConvenience1.swift
//  OnTheMap 2.0
//
//  Created by Xiaochao Luo on 2016-04-20.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation


extension OnTheMapClient {
    
    func queryForLocation(_ completionHandlerForQuery:@escaping (_ result: Int?, _ success: Bool, _ error: NSError?)->Void){
        
        let parameter = ["where" : "{\"uniqueKey\": \"\(self.account_key!)\"}"]
        let urlString = OnTheMapClient.OnTheMapURLFromParseParameters(parameter as [String : AnyObject])
        
//        let request = NSMutableURLRequest(url: urlString)
        var request = URLRequest(url: urlString)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            func sendError(_ error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForQuery(nil, false, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
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
                parsedResults = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
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
                
                completionHandlerForQuery(results?.count, true, error as NSError?)
            }
            
        }) 
        task.resume()
    }
    
    func updateLocation(_ mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandlerForUpdate:@escaping (_ success: Bool, _ error: NSError?)->Void){
        
        print("we are doing it")
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(self.objectID!)"
        let urlString1 = "https://parse.udacity.com/parse/classes/StudentLocation/\(self.objectID!)"
        let url = URL(string: urlString1)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(self.account_key!)\", \"firstName\": \"\(self.firstName!)\", \"lastName\": \"\(self.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            func sendError(_ error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForUpdate(false, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                sendError("there is \(error) in queryForLocation")
                return
            }
            
            guard let data = data else{
                sendError("There is no data in Query")
                return
            }
            
            var parsedResults: AnyObject!
            do{
                parsedResults = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
            }catch {
                sendError("cannot parse the data")
                return
            }

            
            completionHandlerForUpdate(true, error as NSError?)
            
        }) 
        task.resume()
        
    }
    
    func loginViaFacebook(_ accessToken: String, completionHandlerFB:@escaping (_ success: Bool, _ error: NSError?)-> Void){
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        
//        var request1 = URLRequest(url: URL(string:"https://parse.udacity.com/parse/classes/StudentLocation/")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken);\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            func sendError(_ error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerFB(false, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                sendError("there is \(error) in queryForLocation")
                return
            }
            
            guard let data = data else{
                sendError("There is no data in Query")
                return
            }
            
            let dataLength = data.count
            let r = 5...Int(dataLength)
            
            let newData = data.subdata(in: Range(r))
            print(newData)
            let parsedResults: AnyObject!
            do{
                parsedResults = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject!
            }catch {
                sendError("cannot parse the data")
                return
            }
            
            if let account = parsedResults["account"] as? [String:AnyObject]{
                let account_key = account["key"] as? String
                self.account_key = account_key
                completionHandlerFB(true, error as NSError?)
                self.getStudentLocations{(success,result,error) in
                    if success{
                        self.getPublicUserData{(success, lastName,firstName, error) in
                        }
                    }
                }
                
            }
            
        }) 
        task.resume()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
