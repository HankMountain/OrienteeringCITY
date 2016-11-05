/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let locationManager = CLLocationManager()
  
//  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions:[NSObject : AnyObject]? = nil) -> Bool {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]? = nil) -> Bool {
    
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    
    /////UIApplicationLaunchOptionsKey
    ///////Hank_modify_20160927
    /////
    application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
    /////
    ///////Hank_modify_20160927
    /////
    UIApplication.sharedApplication().cancelAllLocalNotifications()
    return true
  }
  
  
  func handleEvent(forRegion region: CLRegion!) {
    // Show an alert if application is active
    
    /////
    ///////Hank_modify_20160927
    /////
    if UIApplication.sharedApplication().applicationState == .Active {
      guard let message = note(fromRegionIdentifier: region.identifier) else { return }
      window?.rootViewController?.showAlert(withTitle: nil, message: message)
    } else {
      // Otherwise present a local notification
      let notification = UILocalNotification()
      notification.alertBody = note(fromRegionIdentifier: region.identifier)
      notification.soundName = "Default"
      
      /////
      ///////Hank_modify_20160927
      /////
      UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
  }
  
  
  
  func note(fromRegionIdentifier identifier: String) -> String? {
    
    /////
    ///////Hank_modify_20160927
    /////
    
    let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(PreferencesKeys.savedItems) as? [NSData]
    
//    let savedItems = NSUserDefaults.standard.array(forKey: PreferencesKeys.savedItems) as? [NSData]
    
    let geotifications = savedItems?.map{ NSKeyedUnarchiver.unarchiveObjectWithData($0 as NSData) as? Geotification }
    
    
//    let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Geotification }
    
    let index = geotifications?.indexOf{ $0?.identifier == identifier }
    
//    let index = geotifications?.index { $0?.identifier == identifier }
    
    return index != nil ? geotifications?[index!]?.note : nil
  }
  
  
}


//Handle region event
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

