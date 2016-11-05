//
//  Utilities.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/9/30.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import MapKit

// MARK: Helper Extensions
extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
}


extension MKMapView {
    func zoomToUserLocation() {
        
        print("BREAK_POINT : In zoomToUserLocation() func")
        
        
        
        guard let coordinate = userLocation.location?.coordinate else {
            
            print("BREAK_POINT : In guard let coordinate = userLocation.location?.coordinate else")
            
            return }
        
        
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        
        
        
        setRegion(region, animated: true)
    }
}

