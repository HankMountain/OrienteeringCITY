//
//  ViewController.swift
//  FirebaseTEST
//
//  Created by Hank on 2016/9/26.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {

    
    let conditionRef = FIRDatabase.database().reference().child("condition")
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func  viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        conditionRef.observeEventType(.Value) { (snap: FIRDataSnapshot) in
            self.conditionLabel.text = snap.value?.description
        }
    }
    
    
    @IBAction func sunnyDidTouch(sender: AnyObject) {
        conditionRef.setValue("Sunny")
    }
    
    
    @IBAction func foggyDidTouch(sender: AnyObject) {
        conditionRef.setValue("Foggy")
    }
    
    
    
    
}

