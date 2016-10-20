//
//  MainPageViewController.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/9/28.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAuth
import MapKit
import CoreData
import Crashlytics

class MainPageViewController: UIViewController {
    
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
        
        print("BREAK_POINT : didTapLogout Facebook and Firebase")
        
        //sign the user out of the firebase app
        try! FIRAuth.auth()!.signOut()
        //sigh the user out of the facebook app
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let logInViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LogInViewController")
        
        self.presentViewController(logInViewController, animated: true, completion: nil )
        
    }
    
    
    
    //Seque to TodayEventViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showTodayEvent" {
            print("BREAK_POINT : Seque to TodayEventViewController")
            segue.destinationViewController as? TodayEventViewController
            
            let backItem = UIBarButtonItem()
            backItem.title = "Main Page"
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

        changeLabelAndImageProperty()

//        Crashlytics.sharedInstance().crash()
    }
    
    
    func changeLabelAndImageProperty(){
        
        //設定logout button的自型/大小/顏色/透明度
        logOutButton.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "AlNile-Bold", size: 12.0)!,
            NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(0.3)],forState: UIControlState.Normal)
        
        todayEventButton.layer.masksToBounds = true
        todayEventButton.layer.cornerRadius = 3
        nextEventButton.layer.masksToBounds = true
        nextEventButton.layer.cornerRadius = 3
        historyButton.layer.masksToBounds = true
        historyButton.layer.cornerRadius = 3
        medalButton.layer.masksToBounds = true
        medalButton.layer.cornerRadius = 3
        
    }

    
}






