//
//  OnTheMapClient.swift
//  OnTheMap 2.0
//
//  Created by Xiaochao Luo on 2016-04-14.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation


class OnTheMapClient: NSObject {
    
    var account_key : String?
    var studentsInfo = [studentInfo]()
    var firstName: String?
    var lastName: String?
    var objectID: String?
    
    func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!,error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: OnTheMapClient.OnTheMapURLFromParameters(parameters, withPathExtension: method))
        let request1 = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request){(data, response, error) in
            
            func sendError(error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                sendError("There is an error with your request \(error)")
                return
            }
            
            guard let data = data else {
                sendError("there is no data when implementing this post method")

                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length-5))
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)

        }
        
        task.resume()
        return task
    }
    
    func taskForGETMethod(method:String, parameters: [String:AnyObject],CompletionHandlerForGET:(result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: OnTheMapClient.OnTheMapURLFromParameters(parameters, withPathExtension: method))
        
        let request1 = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(self.account_key!)")!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request){(data,response,error) in
            
            func sendError(error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                CompletionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                
                sendError("Error happened while implementing GETMethod \(error)")
                return
            }
            
            guard let data = data else {
                
                sendError("No data while implementing GETMethod")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length-5))
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: CompletionHandlerForGET)
        }
        task.resume()
        return task
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result:AnyObject!, error: NSError?) -> Void){
        
        
        var parsedResult: AnyObject!
        
        do{
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        }catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)' "]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    class func OnTheMapURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = OnTheMapClient.Constants.ApiScheme
        components.host = OnTheMapClient.Constants.ApiHost
        components.path = OnTheMapClient.Constants.ApiPath + (withPathExtension ?? "")
        
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
        
    }
    
    class func OnTheMapURLFromParseParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = "parse.udacity.com"
        components.path = "/parse/classes/StudentLocation/" + (withPathExtension ?? "")
        
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
        
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    class func sharedInstance() -> OnTheMapClient {
        struct Singleton {
            static var sharedInstance = OnTheMapClient()
        }
        return Singleton.sharedInstance
    }
    
    
    
    
}