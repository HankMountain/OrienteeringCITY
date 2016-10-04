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

class MainPageViewController: UIViewController {

    
    //點擊登出，退出Firebase and 將Facebook Token設為nil->即登出FB
    @IBAction func didTapLogout(sender: UIButton) {
        
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
        }
    }
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
}
