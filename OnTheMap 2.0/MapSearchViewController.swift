//
//  MapSearchViewController.swift
//  OnTheMap 2.0
//
//  Created by Xiaochao Luo on 2016-04-16.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class MapSearchViewController: UIViewController, UITextFieldDelegate{
    
    var destinyNumber : Int = 0
    var placemark: MKPlacemark!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationSearchTextField: UITextField!
    @IBOutlet weak var URLtextField: UITextField!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var blockView1: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tryAgainLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    
    var thePlaceSearched = String()
    var theWebURL = String()
    
    @IBAction func SearchAgainButton(_ sender: AnyObject) {
        thePlaceSearched = locationSearchTextField.text!
        self.searchAgainButtonTapped()
    }

    @IBAction func searchButton(_ sender: AnyObject) {
        self.searchAdvance{(success, error) in
            if success {
        self.mapView.isHidden = false
        self.blockView.isHidden = true
        self.blockView1.isHidden = false
        self.tryAgainButton.isHidden = false
        self.tryAgainLabel.isHidden = false
        self.label1.isHidden = true
        self.Label2.isHidden = true
        
        self.textFieldShouldReturn(self.locationSearchTextField)
                
                self.ShowBlockView1()
            
            }
        }
        locationSearchTextField.text = ""
    }
    
    
    
    func ShowBlockView1(){
        
        self.blockView1.alpha = 0.0
        view.insertSubview(self.blockView1, aboveSubview: self.mapView)
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {self.blockView1.alpha = 1.0}, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.beforeLaunchPreparation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        self.specialAffect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func submitButton(_ sender: AnyObject) {
        self.submitButtonTapped()
    }
    
        
    func searchAdvance(_ completionHandlerForSearch:@escaping (_ success: Bool, _ error: NSError?)-> Void) {
        
        func sendError(_ error: String){
            let userInfo = [NSLocalizedDescriptionKey: error]
            
            completionHandlerForSearch(false, NSError(domain: "Search Location Function", code: 1, userInfo: userInfo))
        }
        
        guard locationSearchTextField.text != "" else{
            performUIUpdatesOnMain(){
                let alertController = UIAlertController(title: "Error", message: "The Search Phrase is Empty", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            sendError("the text field is empty")
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationSearchTextField.text!) {(placemarks,error) -> Void in
            
            guard error == nil else {
                performUIUpdatesOnMain(){
                    let alertController = UIAlertController(title: "Error", message: "Cannot Locate This Place", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                sendError("There is an error")
                return
            }
            
            guard placemarks!.count > 0 else {
                
                DispatchQueue.main.async(execute: {
                    let alertController = UIAlertController(title: "Error", message: "Cannot Locate The Place", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                })
                sendError("Cannot locate the place")
                return
            }
            
            performUIUpdatesOnMain({
                self.placemark = MKPlacemark(placemark: placemarks![0])
                self.mapView.addAnnotation(self.placemark)
                let region = MKCoordinateRegionMakeWithDistance(self.placemark.coordinate, 100000, 100000)
                self.mapView.setRegion(region, animated: true)
                completionHandlerForSearch(true, error as NSError?)
            })
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func searchAgainButtonTapped(){
        self.mapView.isHidden = true
        blockView.isHidden = false
        blockView1.isHidden = true
        tryAgainButton.isHidden = true
        tryAgainLabel.isHidden = true
        label1.isHidden = false
        Label2.isHidden = false
    }
    
    func specialAffect(){
        self.label1.center.y = self.view.frame.height + 130
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: ({self.label1.center.y = self.view.frame.height/2}), completion: nil)
        
        self.Label2.center.y = self.view.frame.height + 130
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: ({self.Label2.center.y = self.view.frame.height/2}), completion: nil)
        
        self.blockView.center.x = self.view.frame.width + 130
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: ({self.blockView.center.x = self.view.frame.width/2}), completion: nil)
    }
    
    func submitButtonTapped(){
        if destinyNumber == 0 {
            
            OnTheMapClient.sharedInstance().postLocation(self.locationSearchTextField.text!, mediaURL: self.URLtextField.text!, latitude: self.placemark.coordinate.latitude, longitude: self.placemark.coordinate.longitude){( success,error) in
                
                if success {
                    print("we did it")
                    performUIUpdatesOnMain(){
                        self.mapView.isHidden = false
                        self.blockView.isHidden = false
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }else {
            OnTheMapClient.sharedInstance().updateLocation(thePlaceSearched, mediaURL: URLtextField.text!, latitude: self.placemark.coordinate.latitude, longitude: self.placemark.coordinate.longitude){(success,error) in
                
                if success{
                    performUIUpdatesOnMain(){
                        print("we did it")
                        print(self.placemark.coordinate.latitude, self.thePlaceSearched, self.theWebURL)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func beforeLaunchPreparation(){
        tryAgainLabel.isHidden = true
        tryAgainButton.isHidden = true
        locationSearchTextField.delegate = self
        URLtextField.delegate = self
        mapView.isHidden = true
        blockView1.isHidden = true
        blockView.isHidden = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if locationSearchTextField.isFirstResponder {
            locationLabel.isHidden = true
        }else if URLtextField.isFirstResponder {
            linkLabel.isHidden = true
        }
    }
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(MapSearchViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapSearchViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object:nil)
    }
    
    func keyboardWillShow(_ notification: Notification){
        if locationSearchTextField.isFirstResponder {
            locationLabel.isHidden = true
        view.frame.origin.y = -70
//            view.frame.origin.y = -(getKeyboardHeight(notification))
        }else if URLtextField.isFirstResponder{
            linkLabel.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification){
            view.frame.origin.y = 0.0
        }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat{
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey]
            as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

