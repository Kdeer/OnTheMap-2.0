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
    
    @IBAction func SearchAgainButton(sender: AnyObject) {
        self.searchAgainButtonTapped()
    }

    @IBAction func searchButton(sender: AnyObject) {
        self.searchAdvance{(success, error) in
            if success {
        self.mapView.hidden = false
        self.blockView.hidden = true
        self.blockView1.hidden = false
        self.tryAgainButton.hidden = false
        self.tryAgainLabel.hidden = false
        self.label1.hidden = true
        self.Label2.hidden = true
        
        self.textFieldShouldReturn(self.locationSearchTextField)
                
                self.ShowBlockView1()
            
            }
        }
        locationSearchTextField.text = ""
    }
    
    
    
    func ShowBlockView1(){
        
        self.blockView1.alpha = 0.0
        view.insertSubview(self.blockView1, aboveSubview: self.mapView)
        UIView.animateWithDuration(1.0, delay: 0, options: .CurveEaseOut, animations: {self.blockView1.alpha = 1.0}, completion: nil)
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.beforeLaunchPreparation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        self.specialAffect()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func submitButton(sender: AnyObject) {
        self.submitButtonTapped()
        URLtextField.text = ""
    }
    
        
    func searchAdvance(completionHandlerForSearch:(success: Bool, error: NSError?)-> Void) {
        
        func sendError(error: String){
            let userInfo = [NSLocalizedDescriptionKey: error]
            
            completionHandlerForSearch(success: false, error: NSError(domain: "Search Location Function", code: 1, userInfo: userInfo))
        }
        
        guard locationSearchTextField.text != "" else{
            performUIUpdatesOnMain(){
                let alertController = UIAlertController(title: "Error", message: "The Search Phrase is Empty", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            sendError("the text field is empty")
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationSearchTextField.text!) {(placemarks,error) -> Void in
            
            guard error == nil else {
                performUIUpdatesOnMain(){
                    let alertController = UIAlertController(title: "Error", message: "Cannot Locate This Place", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
                sendError("There is an error")
                return
            }
            
            guard placemarks!.count > 0 else {
                
                dispatch_async(dispatch_get_main_queue(),{
                    let alertController = UIAlertController(title: "Error", message: "Cannot Locate The Place", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
                sendError("Cannot locate the place")
                return
            }
            
            performUIUpdatesOnMain({
                self.placemark = MKPlacemark(placemark: placemarks![0])
                self.mapView.addAnnotation(self.placemark)
                let region = MKCoordinateRegionMakeWithDistance(self.placemark.coordinate, 100000, 100000)
                self.mapView.setRegion(region, animated: true)
                completionHandlerForSearch(success: true, error: error)
            })
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func searchAgainButtonTapped(){
        self.mapView.hidden = true
        blockView.hidden = false
        blockView1.hidden = true
        tryAgainButton.hidden = true
        tryAgainLabel.hidden = true
        label1.hidden = false
        Label2.hidden = false
    }
    
    func specialAffect(){
        self.label1.center.y = self.view.frame.height + 130
        UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseOut, animations: ({self.label1.center.y = self.view.frame.height/2}), completion: nil)
        
        self.Label2.center.y = self.view.frame.height + 130
        UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseOut, animations: ({self.Label2.center.y = self.view.frame.height/2}), completion: nil)
        
        self.blockView.center.x = self.view.frame.width + 130
        UIView.animateWithDuration(1, delay: 0, options: .CurveEaseOut, animations: ({self.blockView.center.x = self.view.frame.width/2}), completion: nil)
    }
    
    func submitButtonTapped(){
        if destinyNumber == 0 {
            
            OnTheMapClient.sharedInstance().postLocation(self.locationSearchTextField.text!, mediaURL: self.URLtextField.text!, latitude: self.placemark.coordinate.latitude, longitude: self.placemark.coordinate.longitude){( success,error) in
                
                if success {
                    performUIUpdatesOnMain(){
                        self.mapView.hidden = false
                        self.blockView.hidden = false
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                }
            }
        }else {
            OnTheMapClient.sharedInstance().updateLocation(self.locationSearchTextField.text!, mediaURL: self.URLtextField.text!, latitude: self.placemark.coordinate.latitude, longitude: self.placemark.coordinate.longitude){(success,error) in
                
                if success{
                    performUIUpdatesOnMain(){
                        
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func beforeLaunchPreparation(){
        tryAgainLabel.hidden = true
        tryAgainButton.hidden = true
        locationSearchTextField.delegate = self
        URLtextField.delegate = self
        mapView.hidden = true
        blockView1.hidden = true
        blockView.hidden = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if locationSearchTextField.isFirstResponder() {
            locationLabel.hidden = true
        }else if URLtextField.isFirstResponder() {
            linkLabel.hidden = true
        }
    }
    
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapSearchViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapSearchViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self,name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object:nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        if locationSearchTextField.isFirstResponder() {
            locationLabel.hidden = true
        view.frame.origin.y = -70
//            view.frame.origin.y = -(getKeyboardHeight(notification))
        }else if URLtextField.isFirstResponder(){
            linkLabel.hidden = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
            view.frame.origin.y = 0.0
        }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey]
            as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

