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
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    
//    lazy var ref: FIRDatabaseReference =  { FIRDatabase.database().reference() }()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            Fabric.with([Crashlytics.self])
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
        
        
        
        // Animation Start
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
        self.window!.makeKeyAndVisible()
        
        // rootViewController from StoryBoard
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var navigationController = mainStoryboard.instantiateViewControllerWithIdentifier("LogInViewController")
        self.window!.rootViewController = navigationController
        
        // logo mask
        navigationController.view.layer.mask = CALayer()
        navigationController.view.layer.mask!.contents = UIImage(named: "orienteeringSymbol")!.CGImage
        navigationController.view.layer.mask!.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
        navigationController.view.layer.mask!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        navigationController.view.layer.mask!.position = CGPoint(x: navigationController.view.frame.width / 2, y: navigationController.view.frame.height / 2)
        
        // logo mask background view
        var maskBgView = UIView(frame: navigationController.view.frame)
        maskBgView.backgroundColor = UIColor.whiteColor()
        navigationController.view.addSubview(maskBgView)
        navigationController.view.bringSubviewToFront(maskBgView)
        
        // logo mask animation
        let transformAnimation = CAKeyframeAnimation(keyPath: "bounds")
        transformAnimation.delegate = self
        transformAnimation.duration = 1
        transformAnimation.beginTime = CACurrentMediaTime() + 2 //add delay of 1 second
        let initalBounds = NSValue(CGRect: navigationController.view.layer.mask!.bounds)
        let secondBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let finalBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 2000, height: 2000))
        transformAnimation.values = [initalBounds, secondBounds, finalBounds]
        transformAnimation.keyTimes = [0, 0.5, 1]
        transformAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        transformAnimation.removedOnCompletion = false
        transformAnimation.fillMode = kCAFillModeForwards
        navigationController.view.layer.mask!.addAnimation(transformAnimation, forKey: "maskAnimation")
        
        // logo mask background view animation
        UIView.animateWithDuration(0.1,
                                   delay: 1.35,
                                   options: UIViewAnimationOptions.CurveEaseIn,
                                   animations: {
                                    maskBgView.alpha = 0.0
            },
                                   completion: { finished in
                                    maskBgView.removeFromSuperview()
        })
        
        // root view animation
        UIView.animateWithDuration(0.25,
                                   delay: 1.3,
                                   options: UIViewAnimationOptions.TransitionNone,
                                   animations: {
                                    self.window!.rootViewController!.view.transform = CGAffineTransformMakeScale(1.2, 1.2)
            },
                                   completion: { finished in
                                    UIView.animateWithDuration(0.3,
                                        delay: 0.0,
                                        options: UIViewAnimationOptions.CurveEaseInOut,
                                        animations: {
                                            self.window!.rootViewController!.view.transform = CGAffineTransformIdentity
                                        },
                                        completion: nil
                                    )
        })

        
        
        // Animation Stop
        
        
        return true
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    //用stopNumberCount來限制呼叫handleEvent次數不出過Array參數個數
    var stopNumberCount : Int = 1
    
    //Handle region event
    func handleEvent(forRegion region: CLRegion!){
        
        if stopNumberCount < TodayEventViewController.defaultTodayEventViewController.latitude.count {
        
        //Show an alert if application is active
        //當手機畫面在App裡面時(開啟程式時)，會有pup up
        if UIApplication.sharedApplication().applicationState == .Active {
            guard let message = note(fromRegionIdentifier: region.identifier) else{return}
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
            
            
            print("***進入偵測範圍區域***")
            print("BREAK_POINT : handleEvent_\(message)")
            print("***進入偵測範圍區域***")
            
            let instance2 = TodayEventViewController.defaultTodayEventViewController
            instance2.onAdd()

            
        } else {
            
            //當App在背景執行時，會用此方式show提示，類似推播
            let notification = UILocalNotification()
            notification.alertBody = note(fromRegionIdentifier: region.identifier)
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            
            print("BREAK_POINT : handleEvent_else_\(notification)")

        }
        
        } else {
            
            //這邊可以做遊戲結束處理的功能
            print("恭喜，你已經抵達終點！！！ In Apple deldgate ")
            
            UIAlertView(title: "Congratulations",
                        message: "You have finished the race ! ",
                        delegate:nil,
                        cancelButtonTitle: "OK").show()
            
        }
        
        stopNumberCount += 1
        
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
        saveContext()
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.zedenem.MoonRunner" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
//        return urls[urls.count-1]
        
        return urls.last!
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("OrienteeringCITY", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("OrienteeringCITY.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [NSObject: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }



}





//下列程式碼處理進入或是離開所定義範圍是否要觸發event，call the func handleEvent(forRegion region: CLRegion!)
//to tackle 之後得處理．
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







