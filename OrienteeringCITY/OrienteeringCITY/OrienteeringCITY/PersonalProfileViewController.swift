//
//  PersonalProfileViewController.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/10/21.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class PersonalProfileViewController: UIViewController {

    let firebaseRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileUID: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "logInBackGround.png")!)
        
        FIRAnalytics.logEventWithName("ToPersonalProfile", parameters: nil)

        FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
            kFIRParameterContentType:"PageSelection",
            kFIRParameterItemID:"ToPersonalProfile"
            ])
        
        //設定一些UI參數
        changeLabelAndImageStyle()

        
        //用FireBase抓取User FB相關檔案
        if let user = FIRAuth.auth()?.currentUser {
            
            let name = user.displayName
            let email = user.email
            let photoUrl = user.photoURL
            let uid = user.uid;
            
            self.profileName.text = name
//            self.profileUID.text = uid
            self.profileUID.hidden = true
            
            let storage = FIRStorage.storage()
            let storageRef = storage.referenceForURL("gs://orienteeringcity-dc62e.appspot.com")
            let profilePicRef = storageRef.child(user.uid + "/profile_pic.jpg")
            
            
            profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    print("Unble to download Image")
                } else {
                    if data != nil {
                        self.profilePicture.image = UIImage(data: data!)
                    }
                }
            }
            
            
            
            if self.profilePicture.image == nil {
            
            let profilePicture : FBSDKGraphRequest = FBSDKGraphRequest(graphPath:  "me/picture", parameters: [ "height" : 300 , "width" : 300 , "redirect" : false ], HTTPMethod: "GET")
            profilePicture.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                if error == nil {
                    let dictionary = result as? NSDictionary
                    let data = dictionary?.objectForKey("data")
                    let urlPic = (data?.objectForKey("url"))! as! String
                    
                    if let imageData = NSData(contentsOfURL: NSURL(string: urlPic)!){
                        
                        //將userphoto儲存到Storage的路徑一併塞給
                        self.firebaseRef.child("users/\(uid)/user_photoPathInStorage").setValue("\(profilePicRef)")
                        
                        let uploadTask = profilePicRef.putData(imageData, metadata: nil){
                            metadata, error in
                            
                            if error == nil {
                                let downloadUrl = metadata?.downloadURL
                            } else {
                                print("Fail to get FB picture")
                            }
                        }
                        self.profilePicture.image = UIImage(data: imageData)
                    }
                }
                })
            }
            
        } else {
            print("User did not sign In")
        }
    }

    
    
    func changeLabelAndImageStyle() {
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
    }
    

   

}
