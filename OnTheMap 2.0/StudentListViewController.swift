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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    var studentsInfo : [studentInfo] = [studentInfo]()
    
    @IBAction func logout(_ sender: AnyObject) {
        self.logout()
    }
    
    override func viewDidLoad() {
        studentsTableView.rowHeight = UITableViewAutomaticDimension
        studentsTableView.estimatedRowHeight = 400
    }
    
    
    @IBAction func FBlogOut(_ sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
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
            // ...
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    OnTheMapClient.sharedInstance().getStudentLocations{(success,result,error) in
        
        if success {
            let studentsInfo = result
            self.studentsInfo = studentsInfo!
            performUIUpdatesOnMain(){
                self.studentsTableView.reloadData()
                //self.automaticallyAdjustsScrollViewInsets = false
                self.studentsTableView.contentInset = UIEdgeInsets.zero
            }
        }
        }
    }
}
//    func logout() {
//        dismissViewControllerAnimated(true, completion: nil)
//    }

extension StudentListViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let students = studentsInfo[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableViewCell", for: indexPath) as! StudentTableViewCell
        
        cell.nameLabel.text = (students.firstName ?? "") + " " + (students.lastName ?? "")
        cell.nameLabel.font = UIFont.boldSystemFont(ofSize: 25)
        cell.timeLabel.text = "Updated at:   " + students.updatedAt!
        cell.timeLabel.textColor = UIColor(red: 114 / 255, green: 114 / 255, blue: 114 / 255, alpha: 1.0)
        cell.linkLabel.text = students.mediaURL
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsInfo.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let students = studentsInfo[(indexPath as NSIndexPath).row]
        
        if let toOpen = students.mediaURL {
            let app = UIApplication.shared
            if toOpen.range(of: "https://") != nil || toOpen.range(of: "http://") != nil{
                app.openURL(URL(string: toOpen)!)
            }else if
                toOpen.range(of: "https://") == nil && toOpen.range(of: "http://") == nil {
                app.openURL(URL(string: ("https://" + toOpen))!)
            }
        }
    }
}
