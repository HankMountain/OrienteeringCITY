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

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

class InProcess_1_ViewController: UIViewController {

    
    @IBOutlet weak var mapView1: MKMapView!
    
    
    
    var geotifications : [Geotification] = []
    var locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //1
        //set the viewcontroller as the delegate of locationManager
        locationManager.delegate = self
        // 2
        //要求always geofencing的權限
        locationManager.requestAlwaysAuthorization()
        // 3
        //將剛才在addgeotification新增的點加到地圖上．
        loadAllGeotifications()
        
        //目前先利用delegate的方式呼叫onAdd，把偵測點參數傳過來，之後必須要修正．
        let instance = TodayEventViewController()
        instance.delegate = self
        instance.onAdd()
        
        //測試用，目前似乎只有先加mapView1.showsUserLocation = true 才能Zoom IN
        mapView1.showsUserLocation = true
        locationManager.startUpdatingLocation() //這行沒加也沒差?

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
//        addRadiusOverlay(forGeotification: geotification)
        addRadiusCircle(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    
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
        
        mapView1.delegate = self
        let circle = MKCircle(centerCoordinate: geotification.coordinate, radius: geotification.radius as CLLocationDistance)
        mapView1.addOverlay(circle)
        
    }

   

    // MARK: Map overlay functions //舊的code
//    func addRadiusOverlay(forGeotification geotification: Geotification) {
//        
//        print("BREAK_POINT : addRadiusOverlay")
//
////        self.mapView1.delegate = self
//        mapView1.addOverlay(MKCircle(centerCoordinate: geotification.coordinate as CLLocationCoordinate2D, radius: geotification.radius as CLLocationDistance))
//        
//    }
    
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


    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    
    
    // MARK: Map overlay Renderer //新的code
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
//        if overlay is MKCircle {
            if let overlay = overlay as? MKCircle{
                
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.purpleColor()
            circle.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.2)
            circle.lineWidth = 1
            return circle
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
