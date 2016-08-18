//
//  StudentListViewController.swift
//  OnTheMap 2.0
//
//  Created by Xiaochao Luo on 2016-04-15.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class StudentListViewController: UIViewController {
    
    @IBOutlet weak var studentsTableView: UITableView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    var studentsInfo : [studentInfo] = [studentInfo]()
    
    @IBAction func logout(sender: AnyObject) {
        self.logout()
    }
    
    override func viewDidLoad() {
        studentsTableView.rowHeight = UITableViewAutomaticDimension
        studentsTableView.estimatedRowHeight = 400
    }
    
    
    @IBAction func FBlogOut(sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
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
            // ...
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
        }
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    OnTheMapClient.sharedInstance().getStudentLocations{(success,result,error) in
        
        if success {
            let studentsInfo = result
            self.studentsInfo = studentsInfo!
            performUIUpdatesOnMain(){
                self.studentsTableView.reloadData()
                //self.automaticallyAdjustsScrollViewInsets = false
                self.studentsTableView.contentInset = UIEdgeInsetsZero
            }
        }
        }
    }
}
//    func logout() {
//        dismissViewControllerAnimated(true, completion: nil)
//    }

extension StudentListViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let students = studentsInfo[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentTableViewCell", forIndexPath: indexPath) as! StudentTableViewCell
        
        cell.nameLabel.text = (students.firstName ?? "") + " " + (students.lastName ?? "")
        cell.nameLabel.font = UIFont.boldSystemFontOfSize(25)
        cell.timeLabel.text = "Updated at:   " + students.updatedAt!
        cell.timeLabel.textColor = UIColor(red: 114 / 255, green: 114 / 255, blue: 114 / 255, alpha: 1.0)
        cell.linkLabel.text = students.mediaURL
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsInfo.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let students = studentsInfo[indexPath.row]
        
        if let toOpen = students.mediaURL {
            let app = UIApplication.sharedApplication()
            if toOpen.rangeOfString("https://") != nil || toOpen.rangeOfString("http://") != nil{
                app.openURL(NSURL(string: toOpen)!)
            }else if
                toOpen.rangeOfString("https://") == nil && toOpen.rangeOfString("http://") == nil {
                app.openURL(NSURL(string: ("https://" + toOpen))!)
            }
        }
    }
}
