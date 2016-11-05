//
//  MainPageViewController.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/9/28.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
//import FBSDKCoreKit
import FirebaseAuth
import MapKit
import CoreData
import Crashlytics
import Fabric
import Firebase

class MainPageViewController: UIViewController {
    
    
    let firebaseRef = FIRDatabase.database().reference()
    
    @IBAction func cancelToPlayersViewController(segue:UIStoryboardSegue) {
    }
    
    
    @IBOutlet weak var creatGameButton: UIButton!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var todayEventButton: UIButton!
    @IBOutlet weak var medalButton: UIButton!
    @IBOutlet weak var nextEventButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    
    

    var managedObjectContext: NSManagedObjectContext? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }

    
        //設置UIBarButtonItem為log out button
        //點擊登出，退出Firebase and 將Facebook Token設為nil->即登出FB
    @IBAction func logOutButton(sender: UIBarButtonItem) {
        
//        Crashlytics.sharedInstance().crash()
        
        print("BREAK_POINT : didTapLogout Facebook and Firebase")
        
        //sign the user out of the firebase app
        try! FIRAuth.auth()!.signOut()
        //sigh the user out of the facebook app
//        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let logInViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LogInViewController")
        
        self.presentViewController(logInViewController, animated: true, completion: nil )
        
        
        FIRAnalytics.logEventWithName("UserPressLogOut", parameters: nil)
        
        FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
            kFIRParameterContentType:"PressLogOut",
            kFIRParameterItemID:"PressLogOut"
            ])
        
    }
    
    
    
    //Seque to TodayEventViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showTodayEvent" {
            print("BREAK_POINT : Seque to TodayEventViewController")
            segue.destinationViewController as? TodayEventViewController
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
        }
        
        else if segue.destinationViewController.isKindOfClass(BadgesTableViewController) {
            let fetchRequest = NSFetchRequest(entityName: "RunCoreDataModel")
            
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let runs = (try! managedObjectContext!.executeFetchRequest(fetchRequest)) as! [RunCoreDataModel]
            
            let badgesTableViewController = segue.destinationViewController as! BadgesTableViewController
            badgesTableViewController.badgeEarnStatusesArray = BadgeController.sharedBadgeController.badgeEarnStatusesForRuns(runs)

        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        getUserDataFromFacebook()

        changeLabelAndImageProperty()

    }
    

    
    func changeLabelAndImageProperty(){
        
        //設定logout button的自型/大小/顏色/透明度
        logOutButton.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "AlNile-Bold", size: 12.0)!,
            NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(0.3)],forState: UIControlState.Normal)
        
        todayEventButton.layer.masksToBounds = true
        todayEventButton.layer.cornerRadius = 3
//        nextEventButton.layer.masksToBounds = true
//        nextEventButton.layer.cornerRadius = 3
        historyButton.layer.masksToBounds = true
        historyButton.layer.cornerRadius = 3
        medalButton.layer.masksToBounds = true
        medalButton.layer.cornerRadius = 3
        creatGameButton.layer.masksToBounds = true
        creatGameButton.layer.cornerRadius = 3
        
        //下列程式碼可以做出shadow
        //http://stackoverflow.com/questions/27076419/uibutton-bottom-shadow
//        nextEventButton.backgroundColor = UIColor(red: 171, green: 178, blue: 186, alpha: 1.0)
        // Shadow and Radius
        
        nextEventButton.layer.cornerRadius = 3.0
        nextEventButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor
        nextEventButton.layer.shadowOffset = CGSizeMake(1.5, 1.6)
        nextEventButton.layer.shadowOpacity = 1.0
        nextEventButton.layer.shadowRadius = 0.0
//        nextEventButton.layer.masksToBounds = false
        
        
        creatGameButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor
        creatGameButton.layer.shadowOffset = CGSizeMake(1.5, 1.6)
        creatGameButton.layer.shadowOpacity = 1.0
        creatGameButton.layer.shadowRadius = 0.0
        creatGameButton.layer.masksToBounds = false
        creatGameButton.layer.cornerRadius = 3.0
        
//        navigationController?.navigationBar.barTintColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
        
    }
    
    
    
    
    //Get User Data
//    func getUserDataFromFacebook(){
//        
//        if let user = FIRAuth.auth()?.currentUser {
//            
//            let name = user.displayName
//            let email = user.email
//            let uid = user.uid
//            
//            firebaseRef.child("users/\(uid)/user_name").setValue(name)
//            firebaseRef.child("users/\(uid)/user_email").setValue(email)
//            firebaseRef.child("users/\(uid)/user_uid").setValue(uid)
//            
//            if let name = name {
//            firebaseRef.child("usersNameWithID/\((name))").setValue(uid)
//            }
//            
//        }
//    }

    
}






