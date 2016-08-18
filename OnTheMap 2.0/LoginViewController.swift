//
//  ViewController.swift
//  OnTheMap 2.0
//
//  Created by Xiaochao Luo on 2016-04-14.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var FBLoginButton: FBSDKLoginButton!
    @IBOutlet weak var activator: UIActivityIndicatorView!

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func loginCompleted() {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        
        self.activator.hidden = false
        self.activator.startAnimating()
        if self.usernameTextField.text!.isEmpty || self.passwordTextField.text!.isEmpty{
            let alert = UIAlertController(title: "Error", message: "username or password is empty", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.activator.stopAnimating()
            self.activator.hidden = true
        }else {
        
        OnTheMapClient.sharedInstance().postToLoginSession(self.usernameTextField.text!, password: self.passwordTextField.text!){(success, result, error) in
        
            performUIUpdatesOnMain{
                if success{
                    self.activator.stopAnimating()
                    self.activator.hidden = true
                    self.loginCompleted()
                }else {
                    self.activator.stopAnimating()
                    self.activator.hidden = true
                    let alert = UIAlertController(title: "Error", message: "username or password is Wrong", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activator.hidden = true
        self.FBLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.FBLoginButton.delegate = self
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }
//        var loginButton = FBSDKLoginButton()
//        loginButton.readPermissions = ["public_profile","email","user_friends"]
//        
//        loginButton.delegate = self
//        
//        self.FBLoginButton = loginButton
//        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if FBSDKAccessToken.currentAccessToken() != nil {
        OnTheMapClient.sharedInstance().loginViaFacebook(FBSDKAccessToken.currentAccessToken().tokenString){(success, error) in
            
            performUIUpdatesOnMain{
                if success{
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.FBLogoutNumber = 1
                    self.loginCompleted()

                    
                }else {
                    print("login error")
                }
            }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
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
        if usernameTextField.isFirstResponder() || passwordTextField.isFirstResponder(){
            view.frame.origin.y = -200
            //            view.frame.origin.y = -(getKeyboardHeight(notification))
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

