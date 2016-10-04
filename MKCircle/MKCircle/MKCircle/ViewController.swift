//
//  ViewController.swift
//  MKCircle
//
//  Created by Hank on 2016/10/3.
//  Copyright © 2016年 Hank. All rights reserved.
//

//import UIKit
//
//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//}


import Foundation
import MapKit

class MapViewController: UIViewController{
    var locationManager: CLLocationManager = CLLocationManager()
    
    
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We use a predefined location
        let location = CLLocation(latitude: 25.0424777 as CLLocationDegrees, longitude: 121.5648794 as CLLocationDegrees)
        
        addRadiusCircle(location)
    }
}


    
extension MapViewController : MKMapViewDelegate, CLLocationManagerDelegate{
    
    func addRadiusCircle(location: CLLocation){
        self.mapView.delegate = self
        let circle = MKCircle(centerCoordinate: location.coordinate, radius: 10000 as CLLocationDistance)
        self.mapView.addOverlay(circle)
    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.purpleColor()
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5)
            circle.lineWidth = 1
            return circle
        } else {
            return nil
        }
    }
 
}


