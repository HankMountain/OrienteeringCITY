//
//  MulticolorPolylineSegment.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/10/16.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import MapKit

class MulticolorPolylineSegment: MKPolyline {
    var color: UIColor?
    
    class func colorSegments(forLocations locations: [LocationCoreDataModel]) -> [MulticolorPolylineSegment] {
        var colorSegments = [MulticolorPolylineSegment]()
        
        // RGB for Red (slowest)
//        let red   = (r: 1.0, g: 20.0 / 255.0, b: 44.0 / 255.0)
        let red = (r: 1.0, g: 0.0, b: 0.0)
        
        // RGB for Yellow (middle)
//        let yellow = (r: 1.0, g: 215.0 / 255.0, b: 0.0)
        let yellow = (r: 0.0, g: 1.0, b: 0.0)
        
        // RGB for Green (fastest)
//        let green  = (r: 0.0, g: 146.0 / 255.0, b: 78.0 / 255.0)
        let green  = (r: 0.0, g: 0.0, b: 1.0)
        
        let (speeds, minSpeed, maxSpeed) = allSpeeds(forLocations: locations)
        
        // now knowing the slowest+fastest, we can get mean too
        let meanSpeed = (minSpeed + maxSpeed)/2
        
        for i in 1..<locations.count {
            let l1 = locations[i-1]
            let l2 = locations[i]
            
            var coords = [CLLocationCoordinate2D]()
            
            coords.append(CLLocationCoordinate2D(latitude: l1.latitude!.doubleValue, longitude: l1.longitude!.doubleValue))
            coords.append(CLLocationCoordinate2D(latitude: l2.latitude!.doubleValue, longitude: l2.longitude!.doubleValue))
            
            let speed = speeds[i-1]
            var color = UIColor.blackColor()
            
            if speed < minSpeed { // Between Red & Yellow
                let ratio = (speed - minSpeed) / (meanSpeed - minSpeed)
                let r = CGFloat(red.r + ratio * (yellow.r - red.r))
                let g = CGFloat(red.g + ratio * (yellow.g - red.g))
                let b = CGFloat(red.r + ratio * (yellow.r - red.r))
                color = UIColor(red: r, green: g, blue: b, alpha: 1)
            }
            else { // Between Yellow & Green
                let ratio = (speed - meanSpeed) / (maxSpeed - meanSpeed)
                let r = CGFloat(yellow.r + ratio * (green.r - yellow.r))
                let g = CGFloat(yellow.g + ratio * (green.g - yellow.g))
                let b = CGFloat(yellow.b + ratio * (green.b - yellow.b))
                color = UIColor(red: r, green: g, blue: b, alpha: 1)
            }
            
            let segment = MulticolorPolylineSegment(coordinates: &coords, count: coords.count)
            segment.color = color
            colorSegments.append(segment)
        }
        
        return colorSegments
    }
    
    private class func allSpeeds(forLocations locations: [LocationCoreDataModel]) -> (speeds: [Double], minSpeed: Double, maxSpeed: Double) {
        // Make Array of all speeds. Find slowest and fastest
        var speeds = [Double]()
        var minSpeed = DBL_MAX
        var maxSpeed = 0.0
        
        for i in 1..<locations.count {
            let l1 = locations[i-1]
            let l2 = locations[i]
            
            let cl1 = CLLocation(latitude: l1.latitude!.doubleValue, longitude: l1.longitude!.doubleValue)
            let cl2 = CLLocation(latitude: l2.latitude!.doubleValue, longitude: l2.longitude!.doubleValue)
            
            let distance = cl2.distanceFromLocation(cl1)
            let time = l2.timestamp!.timeIntervalSinceDate(l1.timestamp!)
            let speed = distance/time
            
            minSpeed = min(minSpeed, speed)
            maxSpeed = max(maxSpeed, speed)
            
            speeds.append(speed)
        }
        
        return (speeds, minSpeed, maxSpeed)
    }
    
}

