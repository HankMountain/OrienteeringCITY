//
//  BackUpFunction.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/10/13.
//  Copyright © 2016年 Hank. All rights reserved.
//






//Hank
//此處存放修改程式過程中，已經使用不到的功能．
//




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




// MARK: Map overlay functions //舊的code
//    func addRadiusOverlay(forGeotification geotification: Geotification) {
//
//        print("BREAK_POINT : addRadiusOverlay")
//
////        self.mapView1.delegate = self
//        mapView1.addOverlay(MKCircle(centerCoordinate: geotification.coordinate as CLLocationCoordinate2D, radius: geotification.radius as CLLocationDistance))
//
//    }






//var startLocation: CLLocation!
//var lastLocation: CLLocation!
//var traveledDistance: Double = 0

//方法一
//加入計算行走距離的function
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
////        print("1")
////        print("\(startLocation)")
////        print("\(lastLocation)")
//
//        if startLocation == nil {
//            startLocation = locations.first
//
////            print("4")
////            print("\(startLocation)")
////            print("\(lastLocation)")
//
//        } else {
//            if let lastLocationNew = locations.last {
//
////                print("2")
////                print("\(startLocation)")
////                print("\(lastLocation)")
//
//                let distance = startLocation.distanceFromLocation(lastLocation)
//                let lastDistance = lastLocation.distanceFromLocation(lastLocationNew)
//                traveledDistance += lastDistance
//                traveledDistanceNumber.text = String(format: "%.2f",traveledDistance/1000) ?? "0.00"
//
////                print( "\(startLocation)") //目前看起來startLocation可以抓到固定值沒問題
////                print( "\(lastLocation)") //目前看起來lastLocation可以抓到變化值沒問題
////                print("FULL DISTANCE: \(traveledDistance/1000) Km")
////                print("STRAIGHT DISTANCE: \(distance/1000) Km")
////                print(lastDistance)
//            }
//        }
//
////        print("3")
//
//        lastLocation = locations.last
//
////        print("\(startLocation)")
////        print("\(lastLocation)")
//    }




// MARK: Map overlay Renderer //舊的code

//    func mapView(mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
//
//        if overlay is MKCircle {
////            if let overlay = overlay as? MKCircle {
//
//            let circleRenderer = MKCircleRenderer(overlay: overlay)
//            circleRenderer.lineWidth = 1
//            circleRenderer.strokeColor = UIColor.yellowColor()
//            circleRenderer.fillColor = UIColor.yellowColor().colorWithAlphaComponent(0.5)
//
//            return circleRenderer
//            }
//        return MKOverlayRenderer(overlay: overlay)
//    }




//方法二
//加入計算行走距離的function
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        for location in locations as [CLLocation] {
//            if location.horizontalAccuracy < 20 {
//                //update distance
//                if self.locations.count > 0 {
//                    distance += location.distanceFromLocation(self.locations.last!)
//                }
//
//                //save location
//                self.locations.append(location)
//            }
//        }
//    }





//點擊登出，退出Firebase and 將Facebook Token設為nil->即登出FB
//    @IBAction func didTapLogout(sender: UIButton) {
//
//        print("BREAK_POINT : didTapLogout Facebook and Firebase")
//
//        //sign the user out of the firebase app
//        try! FIRAuth.auth()!.signOut()
//        //sigh the user out of the facebook app
//        FBSDKAccessToken.setCurrentAccessToken(nil)
//
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//
//        let logInViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LogInViewController")
//
//        self.presentViewController(logInViewController, animated: true, completion: nil )
//    }


