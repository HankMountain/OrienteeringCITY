/*
* Copyright (c) 2015 Razeware LLC
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
import HealthKit

class BadgeDetailsViewController: UIViewController {
  var badgeEarnStatus: BadgeEarnStatus!

  @IBOutlet weak var badgeImageView: UIImageView!
  @IBOutlet weak var silverImageView: UIImageView!
  @IBOutlet weak var goldImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var earnedLabel: UILabel!
  @IBOutlet weak var silverLabel: UILabel!
  @IBOutlet weak var goldLabel: UILabel!
  @IBOutlet weak var bestLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle

    let transform = CGAffineTransformMakeRotation(CGFloat(M_PI/8.0))

    nameLabel.text = badgeEarnStatus.badge.name

    let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: badgeEarnStatus.badge.distance!)
    distanceLabel.text = distanceQuantity.description
    badgeImageView.image = UIImage(named: badgeEarnStatus.badge.imageName!)

    if let run = badgeEarnStatus.earnRun {
      earnedLabel.text = "Reached on " + formatter.stringFromDate(run.timestamp)
    }

    if let silverRun = badgeEarnStatus.silverRun {
      silverImageView.transform = transform
      silverImageView.hidden = false
      silverLabel.text = "Earned on " + formatter.stringFromDate(silverRun.timestamp)
    }
    else {
      silverImageView.hidden = true
      let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
      let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: badgeEarnStatus.earnRun!.duration.doubleValue / badgeEarnStatus.earnRun!.distance.doubleValue)
      silverLabel.text = "Pace < \(paceQuantity.description) for silver!"
    }

    if let goldRun = badgeEarnStatus.goldRun {
      goldImageView.transform = transform
      goldImageView.hidden = false
      goldLabel.text = "Earned on " + formatter.stringFromDate(goldRun.timestamp)
    }
    else {
      goldImageView.hidden = true
      let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
      let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: badgeEarnStatus.earnRun!.duration.doubleValue / badgeEarnStatus.earnRun!.distance.doubleValue)
      goldLabel.text = "Pace < \(paceQuantity.description) for gold!"
    }

    if let bestRun = badgeEarnStatus.bestRun {
      let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
      let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: bestRun.duration.doubleValue / bestRun.distance.doubleValue)
      bestLabel.text = "Best: \(paceQuantity.description), \(formatter.stringFromDate(bestRun.timestamp))"
    }
  }

  @IBAction func infoButtonPressed(sender: AnyObject) {
    UIAlertView(title: badgeEarnStatus.badge.name!,
      message: badgeEarnStatus.badge.information!,
      delegate: nil,
      cancelButtonTitle: "OK").show()
  }

}
