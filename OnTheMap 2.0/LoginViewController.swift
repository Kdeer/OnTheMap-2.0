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

    /*!
     @abstract Sent to the delegate when the button was used to login.
     @param loginButton the sender
     @param result The results of the login
     @param error The error (if any) from the login
     */
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("We are loging")
        
        if FBSDKAccessToken.current() == nil {
            print("we don't have token yet")
        }
        
        if FBSDKAccessToken.current() != nil {
            OnTheMapClient.sharedInstance().loginViaFacebook(FBSDKAccessToken.current().tokenString){(success, error) in
                
                performUIUpdatesOnMain{
                    if success{
                        print("we did it")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.FBLogoutNumber = 1
                        self.loginCompleted()
                        
                        
                    }else {
                        print("login error")
                    }
                }
            }
        }
        
    }

    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var FBLoginButton: FBSDKLoginButton!
    @IBOutlet weak var activator: UIActivityIndicatorView!

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func loginCompleted() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func loginButton(_ sender: AnyObject) {
        
        self.activator.isHidden = false
        self.activator.startAnimating()
        if self.usernameTextField.text!.isEmpty || self.passwordTextField.text!.isEmpty{
            let alert = UIAlertController(title: "Error", message: "username or password is empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.activator.stopAnimating()
            self.activator.isHidden = true
        }else {
        
        OnTheMapClient.sharedInstance().postToLoginSession(self.usernameTextField.text!, password: self.passwordTextField.text!){(success, result, error) in
        
            performUIUpdatesOnMain{
                if success{
                    self.activator.stopAnimating()
                    self.activator.isHidden = true
                    self.loginCompleted()
                }else {
                    self.activator.stopAnimating()
                    self.activator.isHidden = true
                    let alert = UIAlertController(title: "Error", message: "username or password is Wrong", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(FBSDKAccessToken.current() == nil)
        {
            print("Not Logged in..")
        }
        else
        {
            print("Logged in..")
        }
        
        self.activator.isHidden = true
        self.FBLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        self.FBLoginButton.delegate = self
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        
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
    
//    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//        
//        print("We are loging")
//        if FBSDKAccessToken.current() != nil {
//        OnTheMapClient.sharedInstance().loginViaFacebook(FBSDKAccessToken.current().tokenString){(success, error) in
//            
//            performUIUpdatesOnMain{
//                if success{
//                    print("we did it")
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDelegate.FBLogoutNumber = 1
//                    self.loginCompleted()
//
//                    
//                }else {
//                    print("login error")
//                }
//            }
//            }
//        }
//    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
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
        if usernameTextField.isFirstResponder || passwordTextField.isFirstResponder{
            view.frame.origin.y = -200
            //            view.frame.origin.y = -(getKeyboardHeight(notification))
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

