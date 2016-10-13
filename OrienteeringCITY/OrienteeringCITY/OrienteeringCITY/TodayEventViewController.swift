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



