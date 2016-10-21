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

class PersonalProfileViewController: UIViewController {

    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileUID: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //設定一些UI參數
        changeLabelAndImageStyle()
        
        //抓取User FB相關檔案
        if let user = FIRAuth.auth()?.currentUser {
            
            let name = user.displayName
            let email = user.email
            let photoUrl = user.photoURL
            let uid = user.uid;
            
            self.profileName.text = name
            let profileImageData = NSData(contentsOfURL: photoUrl!)
            self.profilePicture.image = UIImage(data: profileImageData!)
            
            
            
            
            
        } else {
            // No user is signed in.
        }
        
        
        
        
    }

    
    
    
    
    
    func changeLabelAndImageStyle() {
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
    }
    

   

}
