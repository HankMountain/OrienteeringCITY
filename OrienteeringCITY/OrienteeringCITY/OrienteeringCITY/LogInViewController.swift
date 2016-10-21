//
//  ViewController.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/9/28.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import QuartzCore

class LogInViewController: UIViewController, FBSDKLoginButtonDelegate {
    
        
    @IBOutlet weak var logInPageLoadingSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var logInPageInformationLabel: UILabel!
    
    var loginButton : FBSDKLoginButton = FBSDKLoginButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        changeColorLabelProperty()
        
        logInPageInformationLabel.text = "Hi Runners！" + "\n" + "Please Log In With Facebook Acount. And Start Your Challenge."
        logInPageInformationLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        logInPageInformationLabel.numberOfLines = 0
        
        //設定logInPageInformationLabel相關屬性的code
//        logInPageInformationLabel.layer.masksToBounds = true
//        logInPageInformationLabel.layer.borderColor = UIColor.blackColor().CGColor
//        logInPageInformationLabel.layer.borderWidth = 0.5
//        logInPageInformationLabel.layer.cornerRadius = 5
        
        loginButton.hidden = true
        self.logInPageInformationLabel.hidden = true
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                //move the user to the home screen
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let mainPageViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainNavigationController")
                self.presentViewController(mainPageViewController, animated: true, completion: nil )
                
                
                
            } else {
                // No user is signed in.
                //show the user the login button
                
                //
                //Need to change Log in Button location
                //
                self.loginButton.center = (CGPoint(x: 190, y: 400))
                //
                //Need to change Log in Button location
                //
                
                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                self.loginButton.delegate = self;
                self.view!.addSubview(self.loginButton)
                
                self.loginButton.hidden = false
                self.logInPageInformationLabel.hidden = false

                
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        print("BREAK_POINT : Log In to Facebook")
        
        logInPageLoadingSpinner.startAnimating()
        
        self.loginButton.hidden = true
        self.logInPageInformationLabel.hidden = true
        
        if(error != nil){
            //handle error here
            self.loginButton.hidden = false
            self.logInPageInformationLabel.hidden = false
            logInPageLoadingSpinner.stopAnimating()
            
        }else if(result.isCancelled){
            //handle the cancel event
            self.loginButton.hidden = false
            self.logInPageInformationLabel.hidden = false
            self.logInPageLoadingSpinner.stopAnimating()
            
        }else{
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
            print("BREAK_POINT : Log In to Firebase")
        })
        
   
    }
    
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("BREAK_POINT : Log Out Facebook")
    }
    
    
    
    //修改色塊小方塊的顏色/文字/
    func changeColorLabelProperty() {
        
        
        
    }


}

