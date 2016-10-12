//
//  TodayEventViewController.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/9/30.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import FirebaseStorage


protocol AddGeotificationsViewControllerDelegate {
    func addGeotificationViewController(controller: TodayEventViewController, didAddCoordinate coordinate: CLLocationCoordinate2D,radius: Double, identifier: String, note: String, eventType: EventType)
}



class TodayEventViewController: UIViewController {
    
    static let defaultTodayEventViewController = TodayEventViewController()
    
//    @IBOutlet weak var lat: UILabel!
//    @IBOutlet weak var lng: UILabel!
    
    internal var latitude : [String] = []
    internal var longitude : [String] = []
    internal var radius : [String] = []
    internal var note : [String] = []
    
    let firebaseRef = FIRDatabase.database().reference()
    
    var delegate: AddGeotificationsViewControllerDelegate?
    
    
    //Seque to InProcess_1_ViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showInProcess_1" {
            
            print("BREAK_POINT : Seque to InProcess_1_ViewController")
            
            segue.destinationViewController as? InProcess_1_ViewController
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //利用此func來抓Error
        //FIRDatabase.setLoggingEnabled(true)

        firebaseRef.child("locations").observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
            
            let locationModelInTodayEventViewController = LocationModel()
            locationModelInTodayEventViewController.jsonConvert(snapshot)
            
            TodayEventViewController.defaultTodayEventViewController.latitude = locationModelInTodayEventViewController.latitude
            TodayEventViewController.defaultTodayEventViewController.longitude = locationModelInTodayEventViewController.longitude
            TodayEventViewController.defaultTodayEventViewController.radius = locationModelInTodayEventViewController.radius
            TodayEventViewController.defaultTodayEventViewController.note = locationModelInTodayEventViewController.note
            }
        }

    
    
    //定義單次抓取站點Array的index，起始點跟結束點．
    internal var indexIncrementStart : Int = 0
    internal var indexIncrementEnd : Int = 1
    internal var stopNumberCountInProcess : Int = 0
    
    func onAdd(){
        
        if stopNumberCountInProcess < TodayEventViewController.defaultTodayEventViewController.latitude.count {
        
        for index in indexIncrementStart..<indexIncrementEnd{
            
            print("BREAK_POINT : 此次新增站點為LocationArray第\(indexIncrementStart+1)點")

//            for index in 0..<TodayEventViewController.defaultTodayEventViewController.latitude.count{
                let lat = TodayEventViewController.defaultTodayEventViewController.latitude[index]
                let lon = TodayEventViewController.defaultTodayEventViewController.longitude[index]
                let radius = TodayEventViewController.defaultTodayEventViewController.radius[index]
                let note = TodayEventViewController.defaultTodayEventViewController.note[index]
                
                let coordinate =  CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                
                let identifier = NSUUID().UUIDString
            
                let eventType: EventType = .onEntry ; delegate?.addGeotificationViewController(self, didAddCoordinate: coordinate, radius: Double(radius)!, identifier: identifier, note: note, eventType: eventType)
            }
        indexIncrementStart += 1
        indexIncrementEnd += 1
        stopNumberCountInProcess += 1
        } else {
          
            print("恭喜，你已經抵達終點！！！ In Today Event View Controller")
            
        }
        
        
        
    }

    
    
}






    
    
//        firebaseRef.child("location").child("latitude").observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
//
//            self.lat.text = snapshot.value?.description
//            self.latitude = String(snapshot.value!.description!)
//
//            TodayEventViewController.defaultTodayEventViewController.latitude = self.latitude
//        }
//
//        firebaseRef.child("location").child("longitude").observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
//            self.lng.text = snapshot.value?.description
//            self.longitude = String(snapshot.value!.description!)
//
//            TodayEventViewController.defaultTodayEventViewController.longitude = self.longitude
//        }




    
    //把資料丟給InProcess_1_ViewController的地方
//    func onAdd(){
    
        //單一資料點測試
        //25.0424777,121.5648794
        //Appworks School
        //        let coordinate = CLLocationCoordinate2D(latitude: 25.0424777, longitude: 121.5648794)


//        for location in Locations().locations() {
//            
//            
//            let coordinate = location
//            let radius = 0.0
//            let identifier = NSUUID().UUIDString
//            let note = ""
//            
//            
//            print("BREAK_POINT : 座標圖\(coordinate)")
//            print("BREAK_POINT : 半徑\(radius)")
//            print("BREAK_POINT : 辨認標籤\(identifier)")
//            print("BREAK_POINT : 標記\(note)")
//            
//            let eventType: EventType = .onEntry ; delegate?.addGeotificationViewController(self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note, eventType: eventType)
//            
//            print("BREAK_POINT : 確認eventType是否有被執行以及傳送資料過去In_Pocess_1_\(eventType)")
//            
//        }
        
//    }







// class Locations: NSObject {

//    var a : [CLLocationCoordinate2D] = []
    
//    var delegate: AddGeotificationsViewControllerDelegate?
    
//    static let defaultLocations = Locations()

//    func locations() -> [CLLocationCoordinate2D] {

//    func locations() {

        
//        for index in 0..<TodayEventViewController.defaultTodayEventViewController.latitude.count{
//            let lat = TodayEventViewController.defaultTodayEventViewController.latitude[index]
//            let lon = TodayEventViewController.defaultTodayEventViewController.longitude[index]
//             let radius = TodayEventViewController.defaultTodayEventViewController.radius[index]
//             let note = TodayEventViewController.defaultTodayEventViewController.note[index]
//            
//            let coordinate =  CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
//            
//            let identifier = NSUUID().UUIDString
//
//            
//            let eventType: EventType = .onEntry ; delegate?.addGeotificationViewController(self, didAddCoordinate: coordinate, radius: Double(radius)!, identifier: identifier, note: note, eventType: eventType)

//            self.a.append(location)
         
//        }

        
//        return [CLLocationCoordinate2D(latitude: 25.041, longitude: 121.561),CLLocationCoordinate2D(latitude: 25.041, longitude: 121.561)]
    
//    }
//}



//class Location() {

    //////////
    //此Function僅供插點測試用
//    static let locations : [CLLocationCoordinate2D] = [
    
    //單一資料點測試
    //25.0424777,121.5648794
    //Appworks School
    //        let coordinate = CLLocationCoordinate2D(latitude: 25.0424777, longitude: 121.5648794)
        
    //        CLLocationCoordinate2D(latitude: 25.041, longitude: 121.561),
    //        CLLocationCoordinate2D(latitude: 25.042, longitude: 121.562),
    //        CLLocationCoordinate2D(latitude: 25.043, longitude: 121.563),
    //        CLLocationCoordinate2D(latitude: 25.044, longitude: 121.564),
    //        CLLocationCoordinate2D(latitude: 25.045, longitude: 121.565),
    
    //        CLLocationCoordinate2D(latitude: 25.046, longitude: 121.566),
    //        CLLocationCoordinate2D(latitude: 25.047, longitude: 121.567),
    //        CLLocationCoordinate2D(latitude: 25.048, longitude: 121.568),
    //        CLLocationCoordinate2D(latitude: 25.049, longitude: 121.569),
    //        CLLocationCoordinate2D(latitude: 25.050, longitude: 121.570)
//    ]
    //此Function僅供插點測試用
    //////////

//}

//        CLLocationCoordinate2D(latitude: Double(TodayEventViewController.defaultTodayEventViewController.latitude)!, longitude: Double(TodayEventViewController.defaultTodayEventViewController.longitude)!)


//        for latitude : String in TodayEventViewController.defaultTodayEventViewController.latitude{
//            for longitude : String in TodayEventViewController.defaultTodayEventViewController.longitude{
//                for radius : String in TodayEventViewController.defaultTodayEventViewController.radius{
//                    for note : String in TodayEventViewController.defaultTodayEventViewController.note{
//
//                        CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
//
//                    }
//                }
//
//            }
//        }