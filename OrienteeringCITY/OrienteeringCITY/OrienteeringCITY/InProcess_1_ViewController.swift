//
//  InProcess_1_ViewController.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/9/30.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import HealthKit
import CoreData

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

let SavedDetailSegueName = "RunDetails"


class InProcess_1_ViewController: UIViewController {
    
    
    
    //呼叫位於AppDelegate裡面的managedObjectContext的實體
    var managedObjectContext: NSManagedObjectContext? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    var run: RunCoreDataModel!

    @IBOutlet weak var mapView1: MKMapView!

    var geotifications : [Geotification] = []
    var locationManager = CLLocationManager()
    
    var distance : Double = 0.0
    var seconds : Double = 0.0
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var zoomInButton: UIButton!
    
    
    var locations = [CLLocation]()
    var timer = NSTimer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        mapView1.delegate = self
        
        mapView1.mapType = MKMapType(rawValue: 0)!
        
        //追蹤使用者移動，將畫面中心定為使用者中位置．
        mapView1.userTrackingMode = MKUserTrackingMode(rawValue: 2)!

        // 1
        //set the viewcontroller as the delegate of locationManager
        locationManager.delegate = self
        // 2
        //要求always geofencing的權限
        locationManager.requestAlwaysAuthorization()
        // 3
        //設定地圖最好精準度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 4
        //將剛才在addgeotification新增的點加到地圖上．
        loadAllGeotifications()
        
        
        //目前先利用delegate的方式呼叫onAdd，把偵測點參數傳過來，之後必須要修正．
        let instance = TodayEventViewController.defaultTodayEventViewController
        instance.delegate = self
        instance.onAdd()
     
        //測試用，目前似乎只有先加mapView1.showsUserLocation = true 才能Zoom IN
        mapView1.showsUserLocation = true
        locationManager.activityType = .Fitness
        startPressed()
        
        changeLabelAndButtonStyle()
        
    }
    
    
    func changeLabelAndButtonStyle() {
        
        zoomInButton.layer.masksToBounds = true
        zoomInButton.layer.cornerRadius = 5
        
    }
    

    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        
        print("BREAK_POINT : loadAllGeotifications")
        
        geotifications = []
        
        guard let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(PreferencesKeys.savedItems) else {
            print("BREAK_POINT : guard let savedItems")
            return }
        
        for savedItem in savedItems {
            print("BREAK_POINT : loadAllGeotifications_forinloop")
            guard let geotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geotification else {
                print("BREAK_POINT : guard let geotification")
                continue }
            add(geotification)
        }
    }
    
    
    func saveAllGeotifications() {
        
        print("BREAK_POINT : saveAllGeotifications")
        
        var items: [NSData] = []
        
        for geotification in geotifications {
            
            print("BREAK_POINT : saveAllGeotifications_forinloop")
            
            let item = NSKeyedArchiver.archivedDataWithRootObject(geotification)
            items.append(item)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(items, forKey: PreferencesKeys.savedItems)
        
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func add(geotification: Geotification) {
        
        print("BREAK_POINT : add")
        
        geotifications.append(geotification)
        mapView1.addAnnotation(geotification)
        addRadiusCircle(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    
    // MARK: Remove Geofence Point
    func remove(geotification: Geotification) {
        
        print("BREAK_POINT : remove")
        
        if let indexInArray = geotifications.indexOf(geotification){
            geotifications.removeAtIndex(indexInArray)
        }
        
        mapView1.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    
    //限制新增monitor站點的數量為小於20
    func updateGeotificationsCount() {
        
        print("BREAK_POINT : updateGeotificationsCount")
        
        title = "Geotifications (\(geotifications.count))"
        navigationItem.rightBarButtonItem?.enabled = (geotifications.count < 20)
    }
    
    
    
    // MARK: Map overlay functions //新的code
    func addRadiusCircle(forGeotification geotification: Geotification){
        
        print("BREAK_POINT : addRadiusCircle")
        
//        mapView1.delegate = self
        let circle = MKCircle(centerCoordinate: geotification.coordinate, radius: geotification.radius as CLLocationDistance)
        mapView1.addOverlay(circle)
        
    }


    
    func removeRadiusOverlay(forGeotification geotification: Geotification) {
        
        print("BREAK_POINT : removeRadiusOverlay")
        
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView1?.overlays else { return }
        for overlay in overlays {
            
            print("BREAK_POINT : removeRadiusOverlay_forinloop")
            
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                
                mapView1?.removeOverlay(circleOverlay)

                break
            }
        }
    }
    
    
    
    @IBAction private func zoomToCurrentLocation(sender: AnyObject) {
        
        mapView1.zoomToUserLocation()
        print("BREAK_POINT : zoomToCurrentLocation in InProcess_1_ViewController")
    }
    
    
    
    //畫出geofencing所需要的圓形區域
    func region(withGeotification geotification: Geotification) -> CLCircularRegion {
        
        print("BREAK_POINT : region")
        
        // 1
        //利用CLCircularRegion functnion定義出圓形區域，並且經由geotification model裡面的中心點座標，半徑，畫出來．同時帶有identifier．
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        // 2
        //CLCircularRegion具有辨認物件進入範圍的func，
        region.notifyOnEntry = (geotification.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    
    
    func startMonitoring(geotification: Geotification) {
        
        print("BREAK_POINT : startMonitoring")

        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            showAlert(withTitle:"Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
        }
        
        let region = self.region(withGeotification: geotification)
        locationManager.startMonitoringForRegion(region)
    }
    
    
    
    func stopMonitoring(geotification: Geotification) {
        
        print("BREAK_POINT : stopMonitoring")
        
        for region in locationManager.monitoredRegions {
            
            print("BREAK_POINT : stopMonitoring_forinloop")
            
            guard let circularRegion = region as? CLCircularRegion where circularRegion.identifier == geotification.identifier else { continue }
            
            locationManager.stopMonitoringForRegion(circularRegion)

        }
    }

    
    
    //使用Healthkit定義顯示活動時間/距離/步速
    func eachSecond(timer: NSTimer) {
        seconds += 1
        
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        timeLabel.text = "Running Time: " + secondsQuantity.description
        
        let distanceUnit=HKUnit(fromString: "km")
        let distanceQuantity = HKQuantity(unit: distanceUnit, doubleValue: Double(String(format: "%.2f",distance/1000))!)
        distanceLabel.text = "Total Distance: " + distanceQuantity.description
        
        let paceUnit = HKUnit(fromString: "min/km")
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: Double(String(format: "%.2f",(seconds/60) / (distance/1000)))!)
        paceLabel.text = "Average Pace: " + paceQuantity.description
    }

    
    //
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    
    
    //
    func startPressed(){
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1,target: self,selector: "eachSecond:",userInfo: nil,repeats: true)
        startLocationUpdates()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        //因為ＧＰＳ功能很耗電,所以背景執行時關閉定位功能
        locationManager.stopUpdatingLocation()
        timer.invalidate()
    }
    
    
    
    func saveRun() {
        // 1
        let savedRun = NSEntityDescription.insertNewObjectForEntityForName("RunCoreDataModel",inManagedObjectContext: managedObjectContext!) as! RunCoreDataModel
        savedRun.distance = distance
        savedRun.duration = seconds
        savedRun.timestamp = NSDate()
        
        // 2
        var savedLocations = [LocationCoreDataModel]()

        for location in locations {
 
            let savedLocation = NSEntityDescription.insertNewObjectForEntityForName("LocationCoreDataModel",inManagedObjectContext: managedObjectContext!) as! LocationCoreDataModel
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = location.coordinate.latitude
            savedLocation.longitude = location.coordinate.longitude
            savedLocations.append(savedLocation)
            
        }
        
        // Todo :
        //savedRun.locations是否需要改為NSOrderedSet ?
        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun
        
        // 3
        var error: NSError?
        let success: Bool
        do {
            try managedObjectContext!.save()
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        if !success {
            print("Could not save the run!")
        }
    }
    
    
    @IBAction func savePressed(sender: AnyObject) {
        let actionSheet = UIActionSheet(title: "Run Stopped", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save", "Discard")
        actionSheet.actionSheetStyle = .Default
        actionSheet.showInView(view)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? RunDetailViewController {
            detailViewController.run = run
        }
    }
    

}



// MARK: AddGeotificationViewControllerDelegate
extension InProcess_1_ViewController: AddGeotificationsViewControllerDelegate {
    
    func addGeotificationViewController(controller: TodayEventViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType) {
        
        controller.dismissViewControllerAnimated(true, completion: nil)

        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
        
        add(geotification)
        startMonitoring(geotification)
        saveAllGeotifications()
    }
}



// MARK: - Location Manager Delegate
extension InProcess_1_ViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        mapView1.showsUserLocation = (status == .AuthorizedAlways)
        
        //測試
//        mapView1.showsUserLocation = (true)
        
        print("BREAK_POINT : extension InProcess_1_ViewController: CLLocationManagerDelegate : mapView_1.showsUserLocation")
        
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: NSError) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    
    
    //加入畫使用者路徑的func
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        
        if let oldLocationNew = oldLocation as CLLocation?{
            let oldCoordinates = oldLocationNew.coordinate
            let newCoordinates = newLocation.coordinate
            var area = [oldCoordinates, newCoordinates]
            var polyline = MKPolyline(coordinates: &area, count: area.count)
            mapView1.addOverlay(polyline)
        }

    }
    

    
    //方法二
    //加入計算行走距離的function
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations as [CLLocation] {
            let howRecent = location.timestamp.timeIntervalSinceNow
            if abs(howRecent) < 2 && location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1600, 1600)
                    mapView1.setRegion(region, animated: true)
                    
                    mapView1.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }

    
   
}




// MARK: - MapView Delegate
extension InProcess_1_ViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myGeotification"
        if annotation is Geotification {
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                let removeButton = UIButton(type: .Custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                
                removeButton.setImage(UIImage(named: "DeleteGeotification")!, forState: .Normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    
 
    // MARK: Map overlay Renderer //新的code
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKCircle {
//            if let overlay = overlay as? MKCircle{
            
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.purpleColor()
            circle.fillColor = UIColor.yellowColor().colorWithAlphaComponent(0.2)
            circle.lineWidth = 1
            return circle
        }
        
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.brownColor().colorWithAlphaComponent(0.3)
            polylineRenderer.lineWidth = 3
            return polylineRenderer
        }
        

        return MKOverlayPathRenderer(overlay: overlay)
        
//        else {
//            return nil
//        }
        

    }

    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
        
        let geotification = view.annotation as! Geotification
        stopMonitoring(geotification)
        remove(geotification)
        saveAllGeotifications()
        
    }
    

}


// MARK: - UIActionSheetDelegate
extension InProcess_1_ViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        //save
        if buttonIndex == 1 {
            saveRun()
            performSegueWithIdentifier(SavedDetailSegueName, sender: nil)
        }
            //discard
        else if buttonIndex == 2 {
            navigationController?.popToRootViewControllerAnimated(true)
        }
    }
}

