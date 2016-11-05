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

import Foundation

let silverMultiplier = 1.05 // 5% speed increase
let goldMultiplier = 1.10 // 10% speed increase

class Badge {
  let name: String?
  let imageName: String?
  let information: String?
  let distance: Double?

  init(json: [String: String]) {
    name = json["name"]
    information = json["information"]
    imageName = json["imageName"]
    distance = (json["distance"] as NSString?)?.doubleValue
  }
}

class BadgeController {
  static let sharedController = BadgeController()

  lazy var badges : [Badge] = {
    var _badges = [Badge]()

    let filePath = NSBundle.mainBundle().pathForResource("badges", ofType: "json") as String!
    let jsonData = NSData.dataWithContentsOfMappedFile(filePath) as! NSData

    var error: NSError?
    
    if let jsonBadges =  NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as? [Dictionary<String, String>] {
        
      for jsonBadge in jsonBadges {
        _badges.append(Badge(json: jsonBadge))
        }
    }
    else {
      print(error)
    }

    return _badges
    }()

    
    
    
  func bestBadgeForDistance(distance: Double) -> Badge {
    var bestBadge = badges.first as Badge!
    for badge in badges {
      if distance < badge.distance {
        break
      }
      bestBadge = badge
    }
    return bestBadge
  }

  func nextBadgeForDistance(distance: Double) -> Badge {
    var nextBadge = badges.first as Badge!
    for badge in badges {
      nextBadge = badge
      if distance < badge.distance {
        break
      }
    }
    return nextBadge
  }

  func badgeEarnStatusesForRuns(runs: [Run]) -> [BadgeEarnStatus] {
    var badgeEarnStatuses = [BadgeEarnStatus]()

    for badge in badges {
      let badgeEarnStatus = BadgeEarnStatus(badge: badge)

      for run in runs {
        if run.distance.doubleValue > badge.distance {

          // This is when the badge was first earned
          if badgeEarnStatus.earnRun == nil {
            badgeEarnStatus.earnRun = run
          }

          let earnRunSpeed = badgeEarnStatus.earnRun!.distance.doubleValue / badgeEarnStatus.earnRun!.duration.doubleValue
          let runSpeed = run.distance.doubleValue / run.duration.doubleValue

          // Does it deserve silver?
          if badgeEarnStatus.silverRun == nil && runSpeed > earnRunSpeed * silverMultiplier {
            badgeEarnStatus.silverRun = run
          }

          // Does it deserve gold?
          if badgeEarnStatus.goldRun == nil && runSpeed > earnRunSpeed * goldMultiplier {
            badgeEarnStatus.goldRun = run
          }

          // Is it the best for this distance?
          if let bestRun = badgeEarnStatus.bestRun {
            let bestRunSpeed = bestRun.distance.doubleValue / bestRun.duration.doubleValue
            if runSpeed > bestRunSpeed {
              badgeEarnStatus.bestRun = run
            }
          }
          else {
            badgeEarnStatus.bestRun = run
          }
        }
      }
      
      badgeEarnStatuses.append(badgeEarnStatus)
    }
    
    return badgeEarnStatuses
  }

}

class BadgeEarnStatus {
  let badge: Badge
  var earnRun: Run?
  var silverRun: Run?
  var goldRun: Run?
  var bestRun: Run?

  init(badge: Badge) {
    self.badge = badge
  }
}
