//
//  MapViewController.swift
//  OnTheMap 2.0
//
//  Created by Xiaochao Luo on 2016-04-15.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var studentsInfo : [studentInfo] = [studentInfo]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var mapView: MKMapView!
    var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
    
    @IBAction func searchPlace(sender: AnyObject) {
        self.searchPlaceTapped()
    }
    
    func searchPlaceTapped(){
        OnTheMapClient.sharedInstance().queryForLocation{(result, success, error) in
            
            if error == nil {
                print(result)
            if result != 0 {
                performUIUpdatesOnMain(){
                    let alertController = UIAlertController(title: "Alert", message: "You Have a Pin Already", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "Overwrite", style: .Default) { (action) in
                        self.LinkToMapSearch(1)
                    }
                    alertController.addAction(OKAction)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
                    }
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true) {
                    }
                }
            }else {
                performUIUpdatesOnMain(){
                    self.LinkToMapSearch(0)
                }
                }
            } else {
                print(error)
                print("there is an error when request a new pin")

            }
        }
    }
    
    func LinkToMapSearch(destinyNumber: Int){
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationSearchViewController") as! MapSearchViewController
        controller.destinyNumber = destinyNumber
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func testForQuery(sender: AnyObject) {
        //This is actually a refresh button
        OnTheMapClient.sharedInstance().getStudentLocations{(success, result, error) in
            
            if success {
                performUIUpdatesOnMain(){
                    self.removeAllAnnotations()
                    let results = result
                    self.studentsInfo = results!
                    self.showTheAnnotations()
                }
            }else {
                print(result)
                print(error)
                print("cannot get data through MapViewController")
            }
        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        self.logout()
    }
    
    func logout(){
        let alertController = UIAlertController(title: "Alert", message: "Sure to Logout?", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            
            if self.appDelegate.FBLogoutNumber == 1{
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                self.presentViewController(controller, animated: true, completion: nil)
                
            } else {
                self.appDelegate.FBLogoutNumber = 0
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true) {
        }
    }

    func showTheAnnotations() {
        for info in self.studentsInfo{
            let annotation = MKPointAnnotation()
            
            if info.latitude != nil && info.longitude != nil {
            annotation.coordinate = CLLocationCoordinate2D(latitude: info.latitude, longitude: info.longitude)
            annotation.title = info.firstName! + " " + info.lastName!
            annotation.subtitle = info.mediaURL
            
            self.annotations.append(annotation)
            }
        }
        self.mapView.addAnnotations(annotations)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                if toOpen.rangeOfString("https://") != nil || toOpen.rangeOfString("http://") != nil{
                    app.openURL(NSURL(string: toOpen)!)
                }else if
                    toOpen.rangeOfString("https://") == nil && toOpen.rangeOfString("http://") == nil {
                app.openURL(NSURL(string: ("https://" + toOpen))!)
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        OnTheMapClient.sharedInstance().getStudentLocations{(success, result, error) in
            if success {
                performUIUpdatesOnMain(){
                    self.removeAllAnnotations()
                    let results = result
                    self.studentsInfo = results!
                    self.showTheAnnotations()
                }
            }else {
                print("cannot get data through MapViewController")
            }
        }
    }
    
    func removeAllAnnotations() {
        self.annotations = []
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)
    }
}