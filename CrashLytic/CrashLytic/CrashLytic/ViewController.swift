//
//  ViewController.swift
//  CrashLytic
//
//  Created by Hank on 2016/10/24.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import Crashlytics

class ViewController: UIViewController {

    
    @IBAction func crashButton(sender: AnyObject) {
        
        Crashlytics.sharedInstance().crash()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

