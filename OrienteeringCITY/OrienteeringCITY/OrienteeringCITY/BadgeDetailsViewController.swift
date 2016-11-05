//
//  BadgeDetailsViewController.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/10/20.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import HealthKit
import FirebaseAnalytics

class BadgeDetailsViewController: UIViewController {
    
    var badgeEarnStatus: BadgeEarnStatus!

    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var earnedLabel: UILabel!
    @IBOutlet weak var silverLabel: UILabel!
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var silverImageView: UIImageView!
    @IBOutlet weak var goldImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAnalytics.logEventWithName("ToBadgeDetails", parameters: nil)
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        
        let transform = CGAffineTransformMakeRotation(CGFloat(M_PI/8.0))
        
        nameLabel.text = badgeEarnStatus.badge.name
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: badgeEarnStatus.badge.distance!)
        distanceLabel.text = distanceQuantity.description
        badgeImageView.image = UIImage(named: badgeEarnStatus.badge.imageName!)
        
        if let run = badgeEarnStatus.earnRun {
            earnedLabel.text = "Reached on " + formatter.stringFromDate(run.timestamp!)
        }
        
        if let silverRun = badgeEarnStatus.silverRun {
            silverImageView.transform = transform
            silverImageView.hidden = false
            silverLabel.text = "Earned on " + formatter.stringFromDate(silverRun.timestamp!)
        }
        else {
            silverImageView.hidden = true
            let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
            let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: badgeEarnStatus.earnRun!.duration!.doubleValue / badgeEarnStatus.earnRun!.distance!.doubleValue)
            silverLabel.text = "Pace < \(paceQuantity.description) for silver!"
        }
        
        if let goldRun = badgeEarnStatus.goldRun {
            goldImageView.transform = transform
            goldImageView.hidden = false
            goldLabel.text = "Earned on " + formatter.stringFromDate(goldRun.timestamp!)
        }
        else {
            goldImageView.hidden = true
            let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
            let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: badgeEarnStatus.earnRun!.duration!.doubleValue / badgeEarnStatus.earnRun!.distance!.doubleValue)
            goldLabel.text = "Pace < \(paceQuantity.description) for gold!"
        }
        
        if let bestRun = badgeEarnStatus.bestRun {
            let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
            let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: bestRun.duration!.doubleValue / bestRun.distance!.doubleValue)
            bestLabel.text = "Best: \(paceQuantity.description), \(formatter.stringFromDate(bestRun.timestamp!))"
        }
    }
    
    @IBAction func infoButtonPressed(sender: AnyObject) {
        
        FIRAnalytics.logEventWithName("TouchBadgeDetailInfoButton", parameters: nil)
        
        UIAlertView(title: badgeEarnStatus.badge.name!, message: badgeEarnStatus.badge.information!, delegate: nil, cancelButtonTitle: "ok").show()
        
    }

}
