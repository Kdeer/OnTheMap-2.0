//
//  OnTheMapConvenience.swift
//  OnTheMap 2.0
//
//  Created by Xiaochao Luo on 2016-04-15.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation


extension OnTheMapClient {
    

    func postToLoginSession(_ username: String, password: String, completionHandlerForLogin: @escaping (_ success: Bool, _ result: String?, _ error: NSError?) -> Void){
        
        let parameters = [String:String]()
        let method = OnTheMapClient.Methods.session
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        taskForPOSTMethod(method, parameters: parameters as [String : AnyObject], jsonBody: jsonBody){(result, error) in
            
            if error != nil {
                print(error)
                completionHandlerForLogin(false, nil, error)
            }else{
                print("taskForPostMethod WORKED")
                if let account = result?["account"] as? [String:AnyObject]{
                    let account_key = account["key"] as! String!
                    self.account_key = account_key
                    completionHandlerForLogin(true, account_key, error)
                    self.getStudentLocations{(success,result,error) in
                    }
                    self.getPublicUserData{(success, lastName,firstName, error) in
                    }
                }else {
                    completionHandlerForLogin(false, nil, NSError(domain: "Parsing Login Data", code: 0, userInfo: [NSLocalizedDescriptionKey: "Canot parse postToLoginSession"]))
                }
            }
        }
    }
    
    func getPublicUserData(_ completionHandlerForUserData:@escaping (_ success: Bool,_ lastName: String?,_ firstName: String?, _ error: NSError?) -> Void){
        
        let parameters = [String:String]()
        var mutableMethod = OnTheMapClient.Methods.users
        mutableMethod = OnTheMapClient.sharedInstance().subtituteKeyInMethod(mutableMethod, key: "id", value: String(OnTheMapClient.sharedInstance().self.account_key!))!
        
        taskForGETMethod(mutableMethod, parameters: parameters as [String : AnyObject]){(result,error) in
            
            if error != nil {
                print(error)
                completionHandlerForUserData(false, nil, nil, error!)
            }else{
                print(result)
                let results = result?["user"] as? [String:AnyObject]
                let LastName = results!["last_name"] as? String
                let FirstName = results!["first_name"] as? String
                self.firstName = FirstName
                self.lastName = LastName
                completionHandlerForUserData(true, LastName, FirstName, error)
            }
        }
    }
    
    func getStudentLocations(_ completionHandlerForLocations:@escaping (_ success: Bool, _ result: [studentInfo]?, _ error: NSError?)-> Void){
        
        let parameter: [String:String?] = ["limit" : "50"]
        let url = OnTheMapClient.OnTheMapURLFromParseParameters(parameter as [String : AnyObject])
        
        let request = NSMutableURLRequest(url: url)
        var request1 = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request1.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request1.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request1, completionHandler: { data, response, error in
            
            func sendError(_ error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForLocations(false, nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
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
                parsedResults = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
            }catch {
                sendError("cannot parse the data")
                return
            }
            if let result = parsedResults["results"] as? [[String:AnyObject]]{

                let info = studentInfo.locationsFromResults(result)
                self.studentsInfo = info
                completionHandlerForLocations(true, info, error as NSError?)
            }else{
                sendError("empty parsedResults")
            }
        }) 
        task.resume()
    }
    
    func postLocation(_ mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandlerForPostLocation: @escaping (_ success: Bool, _ error: NSError?) -> Void){
        
        let parameter = [String:String]()
        let url = OnTheMapClient.OnTheMapURLFromParseParameters(parameter as [String : AnyObject])
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(self.account_key!)\", \"firstName\": \"\(self.firstName!)\", \"lastName\": \"\(self.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            
            
            func sendError(_ error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForPostLocation(false, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError("There is an \(error) at getStudentLocations")
                return
            }
            
            guard data != nil else{
                sendError("There is no data at getStudentLocations")
                return
            }
            
            completionHandlerForPostLocation(true, error as NSError?)
            
        })
        
        task.resume()
    }
}
