//
//  RunDetailViewController.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/10/13.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import MapKit

class RunDetailViewController: UIViewController {
    
    var run: RunCoreDataModel!
    
    @IBOutlet weak var mapViewInRunDetail: MKMapView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewInRunDetail.delegate = self
        mapViewInRunDetail.mapType = MKMapType(rawValue: 0)!
        configureView()
    }

    

    func configureView() {
        
        
        let distanceUnit=HKUnit(fromString: "km")
        let distanceQuantity = HKQuantity(unit: distanceUnit, doubleValue: Double(String(format: "%.2f",run.distance!.doubleValue/1000))!)
        distanceLabel.text = "Total Distance: " + distanceQuantity.description
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        dateLabel.text = dateFormatter.stringFromDate(run.timestamp!)
        
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: run.duration!.doubleValue)
        timeLabel.text = "Running Time: " + secondsQuantity.description
        
        let paceUnit = HKUnit(fromString: "min/km")
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: Double(String(format: "%.2f",(run.duration!.doubleValue/60) / (run.distance!.doubleValue/1000)))!)
        paceLabel.text = "Average Pace: " + paceQuantity.description
        
        loadMap()
    }

    
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = run.locations!.firstObject as! LocationCoreDataModel
        
        var minLat = initialLoc.latitude!.doubleValue
        var minLng = initialLoc.longitude!.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = run.locations!.array as! [LocationCoreDataModel]
        
        for location in locations {

            minLat = min(minLat, location.latitude!.doubleValue)
            minLng = min(minLng, location.longitude!.doubleValue)
            maxLat = max(maxLat, location.latitude!.doubleValue)
            maxLng = max(maxLng, location.longitude!.doubleValue)
        }
        
        //回傳一個MKCoordinateRegion包含center/span，畫出包含整個路徑的地圖．
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                longitudeDelta: (maxLng - minLng)*2.0))
    }
    
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        
        if !overlay.isKindOfClass(MulticolorPolylineSegment) {
            return nil
        }
        
        let polyline = overlay as! MulticolorPolylineSegment
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 3
        return renderer
    }
    
    
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = run.locations!.array as! [LocationCoreDataModel]
        
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude!.doubleValue,
                longitude: location.longitude!.doubleValue))
        }
        
        //http://stackoverflow.com/questions/30541244/what-does-a-ampersand-mean-in-the-swift-language
        //describe the "&" usage
        return MKPolyline(coordinates: &coords, count: run.locations!.count)
    }
    
    func loadMap() {
        if run.locations!.count > 0 {
            mapViewInRunDetail.hidden = false
            
            // Set the map bounds
            mapViewInRunDetail.region = mapRegion()
            
            // Make the line(s!) on the map
            let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: run.locations!.array as! [LocationCoreDataModel])
            mapViewInRunDetail.addOverlays(colorSegments)
        } else {
            // No locations were found!
            mapViewInRunDetail.hidden = true
            
            UIAlertView(title: "Error",
                        message: "Sorry, this run has no locations saved",
                        delegate:nil,
                        cancelButtonTitle: "OK").show()
        }
    }


}

// MARK: - MKMapViewDelegate
extension RunDetailViewController: MKMapViewDelegate {
}
