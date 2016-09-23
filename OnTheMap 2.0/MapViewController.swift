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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var mapView: MKMapView!
    var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
    
    @IBAction func searchPlace(_ sender: AnyObject) {
        self.searchPlaceTapped()
        

    }
    
    func searchPlaceTapped(){
        OnTheMapClient.sharedInstance().queryForLocation{(result, success, error) in
            
            if error == nil {
            if result != 0 {

                performUIUpdatesOnMain(){
                    let alertController = UIAlertController(title: "Alert", message: "You Have a Pin Already", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "Overwrite", style: .default) { (action) in
                        self.LinkToMapSearch(1)
                    }
                    alertController.addAction(OKAction)
                    
                    let cancelAction = UIAlertAction(title: "I Want More", style: .default) { (action) in
                        self.LinkToMapSearch(0)
                    }
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true) {
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
    
    func LinkToMapSearch(_ destinyNumber: Int){
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "LocationSearchViewController") as! MapSearchViewController
        controller.destinyNumber = destinyNumber
        self.present(controller, animated: true, completion: nil)
        
//        OnTheMapClient.sharedInstance().updateLocation("Google", mediaURL: "www.google.com", latitude: 47.669549, longitude: -122.1969044){(success,error) in
//            
//            if success{
//                performUIUpdatesOnMain(){
//                    print("we did it")
//                    //                    print(self.placemark.coordinate.latitude, self.thePlaceSearched, self.theWebURL)
////                    self.dismiss(animated: true, completion: nil)
//                }
//            }
//        }
    }
    
    @IBAction func testForQuery(_ sender: AnyObject) {
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

                print(error)
                print("cannot get data through MapViewController")
            }
        }
    }
    
    @IBAction func logout(_ sender: AnyObject) {
        self.logout()
    }
    
    func logout(){
        let alertController = UIAlertController(title: "Alert", message: "Sure to Logout?", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            if self.appDelegate.FBLogoutNumber == 1{
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                self.present(controller, animated: true, completion: nil)
                
            } else {
                self.appDelegate.FBLogoutNumber = 0
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                self.present(controller, animated: true, completion: nil)
            }
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true) {
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func subtituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                if toOpen.range(of: "https://") != nil || toOpen.range(of: "http://") != nil{
                    app.openURL(URL(string: toOpen)!)
                }else if
                    toOpen.range(of: "https://") == nil && toOpen.range(of: "http://") == nil {
                app.openURL(URL(string: ("https://" + toOpen))!)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
