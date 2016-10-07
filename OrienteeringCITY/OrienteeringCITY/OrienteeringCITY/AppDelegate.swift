//
//  AppDelegate.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/9/28.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FBSDKLoginKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    
//    lazy var ref: FIRDatabaseReference =  { FIRDatabase.database().reference() }()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FIRApp.configure()
        
//        FIRConfiguration.sharedInstance().logLevel = .Debug
//        ref.child("events").observeEventType(.Value) { (snapshot) in
//            print(snapshot)
//        }
        
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        return true
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    //Handle region event
    func handleEvent(forRegion region: CLRegion!){
        // Show an alert if application is active
        if UIApplication.sharedApplication().applicationState == .Active {
            guard let message = note(fromRegionIdentifier: region.identifier) else{return}
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
            
            print("***進入偵測範圍區域***")
            print("BREAK_POINT : handleEvent_\(message)")
            print("***進入偵測範圍區域***")
            
        } else {
            
            let notification = UILocalNotification()
            notification.alertBody = note(fromRegionIdentifier: region.identifier)
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            
            print("BREAK_POINT : handleEvent_else_\(notification)")

        }
    }
    
    
    
    func note(fromRegionIdentifier identifier: String) -> String?{
        
        let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(PreferencesKeys.savedItems) as? [NSData]
        let geotifications = savedItems?.map{NSKeyedUnarchiver.unarchiveObjectWithData($0 as NSData) as? Geotification}
        let index = geotifications?.indexOf{ $0?.identifier == identifier }
        return index != nil ? geotifications?[index!]?.note : nil
    }
    
    
    
    
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}





//下列程式碼處理進入或是離開所定義範圍是否要觸發event，call the func handleEvent(forRegion region: CLRegion!)
//to tackle the 之後得處理．
extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
}



