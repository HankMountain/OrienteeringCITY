//
//  ViewController.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/9/28.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
//import FBSDKLoginKit
import Firebase
import FirebaseAuth
import QuartzCore
import FirebaseAnalytics

class LogInViewController: UIViewController {
    
    
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logInPageLogo: UIImageView!
    
    @IBAction func tipsButton(sender: AnyObject) {
        
        let message = "(1)All information is needed to create an account (2)Need an email with proper format : Email25@gmail.com (3)Password should have more than 6 characters"
        UIAlertView(title: "Tips", message: message, delegate: nil, cancelButtonTitle: "OK").show()
        
    }
    
    
    
    @IBAction func signInButton(sender: AnyObject) {
        
        FIRAuth.auth()?.signInWithEmail(emailField.text!, password: passwordField.text!, completion: { user, error in
            if error != nil {
                print(error.debugDescription)
                
                UIAlertView(title: "Tips",
                    message: "If you login the fisrt time, please create an account",
                    delegate:nil,
                    cancelButtonTitle: "OK").show()
                
            }
            else
            {
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let mainPageViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainNavigationController")
                self.presentViewController(mainPageViewController, animated: true, completion: nil )
                
                
            }
            
        })
        
    }
    
    
    @IBAction func creatAccountButton(sender: AnyObject) {
        
        if (nameField.text == nil) || (nameField.text == ""){
            UIAlertView(title: "Tips",
                        message: "Please enter you name",
                        delegate:nil,
                        cancelButtonTitle: "OK").show()
            return
        }
        else
        {
            FIRAuth.auth()?.createUserWithEmail(emailField.text!, password: passwordField.text!, completion: { user, error in
                if error != nil {
                    print(error.debugDescription)
                    UIAlertView(title: "Tips",
                        message: "Please Check if all the informations have been add correctly",
                        delegate:nil,
                        cancelButtonTitle: "OK").show()
                    return
                }
                else
                {
                    //                let uid = user!.uid
                    let firebaseRef = FIRDatabase.database().reference()
                    
                    if let user = FIRAuth.auth()?.currentUser {
                        
                        let name = self.nameField.text
                        let email = user.email
                        let uid = user.uid
                        let password = self.passwordField.text
                        
                        firebaseRef.child("users/\(uid)/user_name").setValue(name)
                        firebaseRef.child("users/\(uid)/user_email").setValue(email)
                        firebaseRef.child("users/\(uid)/user_uid").setValue(uid)
                        firebaseRef.child("users/\(uid)/user_password").setValue(password)
                        
                        if let name = name {
                            firebaseRef.child("usersNameWithID/\((name))").setValue(uid)
                        }
                        
                        UIAlertView(title: "Congrats",
                            message: "Create account success",
                            delegate:nil,
                            cancelButtonTitle: "OK").show()
                        
                    }
                }
            })
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "logInBackGround.png")!)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if  user != nil {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let mainPageViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainNavigationController")
                self.presentViewController(mainPageViewController, animated: true, completion: nil )
            }
            else
            {
                print("沒登入")
            }
            
            
            
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        nameField.placeholder = "Hank Tsai"
        emailField.placeholder = "OrienteeringCITY@gmail.com"
        passwordField.placeholder = "Password"
        emailField.keyboardType = .EmailAddress
    }
    
    
    
 }
    
    
    
    
    
    
    
    
    
    
    
    

    
//    @IBOutlet weak var logInPageLoadingSpinner: UIActivityIndicatorView!
//    @IBOutlet weak var logInPageInformationLabel: UILabel!
//
////    var loginButton : FBSDKLoginButton = FBSDKLoginButton()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        //修改Spinner大小
//        logInPageLoadingSpinner.transform = CGAffineTransformMakeScale(2.0, 2.0)
//        
//        //修改background為圖片
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "logInBackGround.png")!)
//        
//        changeColorLabelProperty()
//        
//        logInPageInformationLabel.text = "Hi Runners！" + "\n" + "Please Log In With Below Informations. And Start Your Challenge."
//        logInPageInformationLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
//        logInPageInformationLabel.numberOfLines = 0
//        
//        //設定logInPageInformationLabel相關屬性的code
////        logInPageInformationLabel.layer.masksToBounds = true
////        logInPageInformationLabel.layer.borderColor = UIColor.blackColor().CGColor
////        logInPageInformationLabel.layer.borderWidth = 0.5
////        logInPageInformationLabel.layer.cornerRadius = 5
//        
//        loginButton.hidden = true
//        self.logInPageInformationLabel.hidden = true
//        
//        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
//            if user != nil {
//                // User is signed in.
//                //move the user to the home screen
//                
//                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let mainPageViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainNavigationController")
//                self.presentViewController(mainPageViewController, animated: true, completion: nil )
//                
//                FIRAnalytics.logEventWithName(kFIREventLogin, parameters: [
//                    kFIRParameterContentType:"AlreadyLogIn",
//                    kFIRParameterItemID:"AlreadyLogIn"
//                    ])
//                
//                
//            } else {
//                // No user is signed in.
//                //show the user the login button
//                
//                //
//                //Need to change Log in Button location
//                //
//                
//                let funnScreenHeight = UIScreen.mainScreen().bounds.maxY
//                let funnScreenWidth = UIScreen.mainScreen().bounds.maxX
//                let centerPointHeight = funnScreenHeight*0.6
//                let centerPointWidth = funnScreenWidth*0.5
//                self.loginButton.center = CGPoint(x: centerPointWidth, y: centerPointHeight)
//                
////                let fullScreenSize = UIScreen.mainScreen().bounds.size
////                let centerPointHeight = fullScreenSize.height*0.5
////                let centerPointWidth = fullScreenSize.width*0.5
////                self.loginButton.center = CGPoint(x: centerPointHeight, y: centerPointWidth)
//                
//                
////                let framePointHeight = self.view.frame.height/4
////                let framePointWidth = self.view.frame.width/2
////                self.loginButton.center = CGPoint(x: framePointHeight, y: framePointWidth)
//                
//                //
//                //Need to change Log in Button location
//                //
//                
//                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
//                self.loginButton.delegate = self;
//                self.view!.addSubview(self.loginButton)
//                
//                self.loginButton.hidden = false
//                self.logInPageInformationLabel.hidden = false
//                
//                
//                FIRAnalytics.logEventWithName(kFIREventLogin, parameters: [
//                    kFIRParameterContentType:"FirstLogIn",
//                    kFIRParameterItemID:"FirstLogIn"
//                    ])
//                
//            }
//        }
//        
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

    
//    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
//        
//        print("BREAK_POINT : Log In to Facebook")
//        
//        logInPageLoadingSpinner.startAnimating()
//        
//        self.loginButton.hidden = true
//        self.logInPageInformationLabel.hidden = true
//        
//        if(error != nil){
//            //handle error here
//            self.loginButton.hidden = false
//            self.logInPageInformationLabel.hidden = false
//            logInPageLoadingSpinner.stopAnimating()
//            
//        }else if(result.isCancelled){
//            //handle the cancel event
//            self.loginButton.hidden = false
//            self.logInPageInformationLabel.hidden = false
//            self.logInPageLoadingSpinner.stopAnimating()
//            
//        }else{
//        
//        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
//        
//        
//        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
//            print("BREAK_POINT : Log In to Firebase")
//        })
//        
//   
//    }
//    
//    }
//    
//    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
//        print("BREAK_POINT : Log Out Facebook")
//    }
    
    
    
    //修改色塊小方塊的顏色/文字/
//    func changeColorLabelProperty() {
//   
//    }
    












