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



class TodayEventViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    static let defaultTodayEventViewController = TodayEventViewController()
    
//    @IBOutlet weak var lat: UILabel!
//    @IBOutlet weak var lng: UILabel!
    
    @IBOutlet weak var event_titleLabel: UILabel!
    @IBOutlet weak var event_image: UIImageView!
    @IBOutlet weak var event_textLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var todayEventMap: MKMapView!
    
    
    //由Firebase塞入資料，準備傳給下一個Runnug頁面
    internal var latitude : [String] = []
    internal var longitude : [String] = []
    internal var radius : [String] = []
    internal var note : [String] = []
    
    //由Firebase塞入資料，作為本頁面資料顯示
    internal var event_imageURL : String = ""
    internal var event_lat : String = ""
    internal var event_lng : String = ""
    internal var event_text : String = ""
    internal var event_title : String = ""
    internal var event_difficulty : String = ""
    
    
    
    let firebaseRef = FIRDatabase.database().reference()
    
    var delegate: AddGeotificationsViewControllerDelegate?
    
    
    //Seque to InProcess_1_ViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showInProcess_1" {
            
            print("BREAK_POINT : Seque to InProcess_1_ViewController")
            
            segue.destinationViewController as? InProcess_1_ViewController
            
        }
    }
    
    var backBtn = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.tintColor = UIColor(red: 245/255, green: 206/255, blue: 45/255, alpha: 1.0)
        propertyForLabelAndMap()
    }
    
    
    let regionRadius : CLLocationDistance = 300
    
    func zoomInToStartLocation(location: CLLocation){

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        todayEventMap.setRegion(coordinateRegion, animated: true)
        
    }
    
    
    
    
    //定意Map以及Label的參數
    func propertyForLabelAndMap(){
        
        event_image.layer.masksToBounds = true
        event_image.layer.cornerRadius = 10
        event_textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        event_textLabel.numberOfLines = 0
        startButton.layer.masksToBounds = true
        startButton.layer.cornerRadius = 5
        difficultyLabel.layer.masksToBounds = true
        difficultyLabel.layer.cornerRadius = 5
        countDownLabel.layer.masksToBounds = true
        countDownLabel.layer.cornerRadius = 5
        
    }
    
    //Loading此頁面顯示資料
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        firebaseRef.child("events").observeEventType(.Value) { (snapshot:FIRDataSnapshot) in
            
            if let events = snapshot.value as? [NSDictionary] {
                for event : NSDictionary in events {
                    if let eventDetail = event as? [String:AnyObject]{
                        if (eventDetail["event_type"] as! String ) == "today_event" {
                            
                            guard let eventDetailDictionary = eventDetail as? [String:String] else {fatalError()}

                            TodayEventViewController.defaultTodayEventViewController.event_title = eventDetailDictionary["event_title"]!
                            TodayEventViewController.defaultTodayEventViewController.event_text = eventDetailDictionary["event_text"]!
                            TodayEventViewController.defaultTodayEventViewController.event_imageURL = eventDetailDictionary["event_imageURL"]!
                            TodayEventViewController.defaultTodayEventViewController.event_difficulty =
                                eventDetailDictionary["event_difficulty"]!
                            TodayEventViewController.defaultTodayEventViewController.event_lat =
                                eventDetailDictionary["event_lat"]!
                            TodayEventViewController.defaultTodayEventViewController.event_lng =
                                eventDetailDictionary["event_lng"]!
                            
                            

                            self.event_titleLabel.text = TodayEventViewController.defaultTodayEventViewController.event_title
                            self.event_textLabel.text = TodayEventViewController.defaultTodayEventViewController.event_text
                            self.difficultyLabel.text = TodayEventViewController.defaultTodayEventViewController.event_difficulty
                            
                            FIRStorage.storage().referenceForURL(TodayEventViewController.defaultTodayEventViewController.event_imageURL).dataWithMaxSize(10 * 1024 * 1024, completion: { (data, error) -> Void in
                                if error != nil {return}
                                else{
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.event_image.image = UIImage(data: data!)
                                }
                                }})
                            
                            //插大頭針
                            let annotationForToday = TodayEventAnnotation(title: TodayEventViewController.defaultTodayEventViewController.event_title, subtitle: "\(TodayEventViewController.defaultTodayEventViewController.event_lat),\(TodayEventViewController.defaultTodayEventViewController.event_lng)" , coordinate: CLLocationCoordinate2D(latitude: Double(TodayEventViewController.defaultTodayEventViewController.event_lat)!, longitude: Double(TodayEventViewController.defaultTodayEventViewController.event_lng)!))
                            self.todayEventMap.addAnnotation(annotationForToday)
                            
                            //Zoom In 大頭針
                            let centerOfStationWithMap = CLLocation.init(latitude: Double(TodayEventViewController.defaultTodayEventViewController.event_lat)!, longitude: Double(TodayEventViewController.defaultTodayEventViewController.event_lng)!)
                            self.zoomInToStartLocation(centerOfStationWithMap)
                            
                        }
                    }
                }
            }
        }
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

//定義AnnotationM Class
class TodayEventAnnotation : NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title:String, subtitle:String, coordinate:CLLocationCoordinate2D){
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}





