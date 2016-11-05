//
//  LocationModel.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/10/6.
//  Copyright © 2016年 Hank. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

public class LocationModel {
    
    
    var latitude : [String] = []
    var longitude : [String] = []
    var radius : [String] = []
    var note : [String] = []
    
    public func jsonConvert(snapshot: FIRDataSnapshot) {

        
        if let locations = snapshot.value as? [NSDictionary] {
            
            for location : NSDictionary in locations {

                if let locationDetail = location as? [String:AnyObject] {

                    latitude.append(locationDetail["latitude"] as? String ?? "")
                    longitude.append(locationDetail["longitude"] as? String ?? "")
                    radius.append(locationDetail["radius"] as? String ?? "")
                    note.append(locationDetail["note"] as? String ?? "")

                }

            }
            
        }
    }
    
}





//            if let latitude = location["latitude"] as? String{
//                latitudeArray.append(latitude)
//
//                print(latitude)
//            }
//            if let longitude = location["longitude"] as? String{
//                longitudeArray.append(longitude)
//
//                print(longitude)
//            }
//            if let radius = location["radius"] as? String{
//                radiusArray.append(radius)
//
//                print(radius)
//            }
//            if let note = location["note"] as? String{
//                noteArray.append(note)
//
//                print(note)
//            }



