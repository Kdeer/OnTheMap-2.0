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
    
    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?,_ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: OnTheMapClient.OnTheMapURLFromParameters(parameters, withPathExtension: method))
        let request1 = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            
            func sendError(_ error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                sendError("There is an error with your request \(error)")
                return
            }
            
            guard let data = data else {
                sendError("there is no data when implementing this post method")

                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            let dataLength = data.count
            let r = 5...Int(dataLength)
            
            let newData = data.subdata(in: Range(r))

            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)

        })
        
        task.resume()
        return task
    }
    
    func taskForGETMethod(_ method:String, parameters: [String:AnyObject],CompletionHandlerForGET:@escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = URLRequest(url: OnTheMapClient.OnTheMapURLFromParameters(parameters, withPathExtension: method))
        
        let request1 = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(self.account_key!)")!)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {(data,response,error) in
            
            func sendError(_ error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                CompletionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                
                sendError("Error happened while implementing GETMethod \(error)")
                return
            }
            
            guard let data = data else {
                
                sendError("No data while implementing GETMethod")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            let dataLength = data.count
            let r = 5...Int(dataLength)
            
            let newData = data.subdata(in: Range(r))
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: CompletionHandlerForGET)
        })
        task.resume()
        return task
    }
    
    fileprivate func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result:AnyObject?, _ error: NSError?) -> Void){
        
        
        var parsedResult: AnyObject!
        
        do{
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
        }catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)' "]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    func subtituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    class func OnTheMapURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = OnTheMapClient.Constants.ApiScheme
        components.host = OnTheMapClient.Constants.ApiHost
        components.path = OnTheMapClient.Constants.ApiPath + (withPathExtension ?? "")
        
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
        
    }
    
    class func OnTheMapURLFromParseParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "parse.udacity.com"
        components.path = "/parse/classes/StudentLocation/" + (withPathExtension ?? "")
        
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
        
    }
    
    func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    
    class func sharedInstance() -> OnTheMapClient {
        struct Singleton {
            static var sharedInstance = OnTheMapClient()
        }
        return Singleton.sharedInstance
    }
    
    
    
    
}
