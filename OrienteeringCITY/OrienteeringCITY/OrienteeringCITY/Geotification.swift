//
//  Geotification.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/9/30.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


struct GeoKey {
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let radius = "radius"
    static let identifier = "identifier"
    static let note = "note"
    static let eventType = "eventType"
}


enum EventType: String {
    case onEntry = "On Entry"
//    case onExit = "On Exit"
}


class Geotification: NSObject, MKAnnotation,NSCoding {
    
    //宣告會使用到的變數
    var coordinate : CLLocationCoordinate2D
    var radius : CLLocationDistance
    var identifier : String
    var note : String
    var eventType : EventType
    
    
    //宣告annotation的title(MKAnnotation protocol的optional func)
    var title: String? {
        if note .isEmpty {
            return "沒註記"
        } else{
            return note
        }
    }
    
    //宣告annotation的subtitle(MKAnnotation protocol的optional func)
    var subtitle: String? {
        let eventTypeString = eventType.rawValue
        return "偵查半徑 : \(radius)m - \(eventTypeString)"
    }

    
    
    //若呼叫MKAnnotation protocol即須遵守如下規則
    //缺乏init，就給變數init
    init(coordinate : CLLocationCoordinate2D, radius : CLLocationDistance, identifier : String, note : String, eventType : EventType){
        
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.eventType = eventType
        
    }
    
 
    /*
    enum的rawValue
    
    配合rawValue定義enum的值，可以讓enum自帶有意義的資訊。
    
    enum Pet: String {
        case Dog = "🐶"
        case Cat = "🐱"
        case Rabbit = "🐰"
    }
    
    var myPet = Pet.Rabbit
    println("my pet is a \(myPet.rawValue)")    //output: my pet is a 🐰
    
    */
    
    
    //呼叫了NSCoding之後須遵守如下兩個protocol
    // MARK: NSCoding
    required init?(coder decoder: NSCoder){
        
        let latitude = decoder.decodeDoubleForKey(GeoKey.latitude)
//        print("BREAK_POINT : required init?(coder decoder: NSCoder)_latitude\(latitude)")

        let longitude = decoder.decodeDoubleForKey(GeoKey.longitude)
//        print("BREAK_POINT : required init?(coder decoder: NSCoder)_longitude\(longitude)")
        
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        print("BREAK_POINT : required init?(coder decoder: NSCoder)_coordinate\(coordinate)")
        
        radius = decoder.decodeDoubleForKey(GeoKey.radius)
//        print("BREAK_POINT : required init?(coder decoder: NSCoder)_radius\(radius)")
        
        identifier = decoder.decodeObjectForKey(GeoKey.identifier) as! String
//        print("BREAK_POINT : required init?(coder decoder: NSCoder)_identifier\(identifier)")
        
        note = decoder.decodeObjectForKey(GeoKey.note) as! String
//        print("BREAK_POINT : required init?(coder decoder: NSCoder)_note\(note)")
        
        
        eventType = EventType(rawValue: decoder.decodeObjectForKey(GeoKey.eventType) as! String)!
//        eventType = decoder.decodeObjectForKey(GeoKey.eventType) as! EventType
//        print("BREAK_POINT : required init?(coder decoder: NSCoder)_eventType\(eventType)")

    }
    
    
    // MARK: Encoding
    func encodeWithCoder(coder: NSCoder){
        
        coder.encodeDouble(coordinate.latitude, forKey: GeoKey.latitude)
        coder.encodeDouble(coordinate.longitude, forKey: GeoKey.longitude)
        coder.encodeDouble(radius, forKey: GeoKey.radius)
        coder.encodeObject(identifier, forKey: GeoKey.identifier)
        coder.encodeObject(note, forKey: GeoKey.note)
        coder.encodeObject(eventType.rawValue, forKey: GeoKey.eventType)
        
        
//        print("BREAK_POINT : encodeWithCoder_latitude\(coordinate.latitude) with key \(GeoKey.latitude)")
//        print("BREAK_POINT : encodeWithCoder_longitude\(coordinate.longitude) with key \(GeoKey.longitude)")
//        print("BREAK_POINT : encodeWithCoder_radius\(radius) with key \(GeoKey.radius)")
        print("BREAK_POINT : encodeWithCoder_identifier\(identifier) with key \( GeoKey.identifier)")
        print("BREAK_POINT : encodeWithCoder_note\(note) with key \(GeoKey.note)")
//        print("BREAK_POINT : encodeWithCoder_rawValue\(eventType.rawValue) with key \(GeoKey.eventType)")
    }
    
    
}
