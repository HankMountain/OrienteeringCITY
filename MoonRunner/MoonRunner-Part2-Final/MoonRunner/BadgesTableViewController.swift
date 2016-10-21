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

class BadgesTableViewController: UITableViewController {
  var badgeEarnStatusesArray: [BadgeEarnStatus]!

  let redColor = UIColor(red: 1, green: 20/255, blue: 44/255, alpha: 1)
  let greenColor = UIColor(red: 0, green: 146/255, blue: 78/255, alpha: 1)
  let dateFormatter: NSDateFormatter = {
    let _dateFormatter = NSDateFormatter()
    _dateFormatter.dateStyle = .MediumStyle
    return _dateFormatter
    }()
  let transform = CGAffineTransformMakeRotation(CGFloat(M_PI/8.0))

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.destinationViewController.isKindOfClass(BadgeDetailsViewController) {
      let badgeDetailsViewController = segue.destinationViewController as! BadgeDetailsViewController
      let badgeEarnStatus = badgeEarnStatusesArray[tableView.indexPathForSelectedRow!.row]
      badgeDetailsViewController.badgeEarnStatus = badgeEarnStatus
    }
  }

}

// MARK: - UITableViewDataSource
extension BadgesTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return badgeEarnStatusesArray.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("BadgeCell") as! BadgeCell

    let badgeEarnStatus = badgeEarnStatusesArray[indexPath.row]

    cell.silverImageView.hidden = (badgeEarnStatus.silverRun != nil)
    cell.goldImageView.hidden = (badgeEarnStatus.goldRun != nil)

    if let earnRun = badgeEarnStatus.earnRun {
      cell.nameLabel.textColor = greenColor
      cell.nameLabel.text = badgeEarnStatus.badge.name!
      cell.descLabel.textColor = greenColor
      cell.descLabel.text = "Earned: " + dateFormatter.stringFromDate(earnRun.timestamp)
      cell.badgeImageView.image = UIImage(named: badgeEarnStatus.badge.imageName!)
      cell.silverImageView.transform = transform
      cell.goldImageView.transform = transform
      cell.userInteractionEnabled = true
    }
    else {
      cell.nameLabel.textColor = redColor
      cell.nameLabel.text = "?????"
      cell.descLabel.textColor = redColor
      let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: badgeEarnStatus.badge.distance!)
      cell.descLabel.text = "Run \(distanceQuantity.description) to earn"
      cell.badgeImageView.image = UIImage(named: badgeEarnStatus.badge.imageName!)
      cell.userInteractionEnabled = false
    }

    return cell
  }
}
