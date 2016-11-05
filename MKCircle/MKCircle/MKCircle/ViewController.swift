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

import UIKit
import Foundation
import MapKit

class MapViewController: UIViewController{
    var locationManager: CLLocationManager = CLLocationManager()
    
    
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //顯示單一Location的寫法
        // We use a predefined location
//        let location = CLLocation(latitude: 25.0424777, longitude: 121.5648794)
//        
//        addRadiusCircle(location)
        
        
        //顯示複數Location的寫法
        for location in Locatoins.locations {
            addRadiusCircle(location)
        }
        
        
    }
}


    
extension MapViewController : MKMapViewDelegate, CLLocationManagerDelegate{
    
    func addRadiusCircle(location: CLLocation){
        self.mapView.delegate = self
        let circle = MKCircle(centerCoordinate: location.coordinate, radius: 500 as CLLocationDistance)
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




//新增一個Class專門放Locations
class Locatoins {
    
    static let locations : [CLLocation] = [
        
        CLLocation(latitude: 25.041, longitude: 121.5645),
        CLLocation(latitude: 25.042, longitude: 121.5641),
        CLLocation(latitude: 25.043, longitude: 121.5642),
        CLLocation(latitude: 25.044, longitude: 121.5643),
        CLLocation(latitude: 25.045, longitude: 121.5644),
        
        CLLocation(latitude: 25.046, longitude: 121.5645),
        CLLocation(latitude: 25.047, longitude: 121.5641),
        CLLocation(latitude: 25.048, longitude: 121.5642),
        CLLocation(latitude: 25.049, longitude: 121.5643),
        CLLocation(latitude: 25.050, longitude: 121.5644),
        
        CLLocation(latitude: 25.051, longitude: 121.5645),
        CLLocation(latitude: 25.052, longitude: 121.5641),
        CLLocation(latitude: 25.053, longitude: 121.5642),
        CLLocation(latitude: 25.054, longitude: 121.5643),
        CLLocation(latitude: 25.055, longitude: 121.5644),
        
        CLLocation(latitude: 25.056, longitude: 121.5645),
        CLLocation(latitude: 25.057, longitude: 121.5641),
        CLLocation(latitude: 25.058, longitude: 121.5642),
        CLLocation(latitude: 25.059, longitude: 121.5643),
        CLLocation(latitude: 25.060, longitude: 121.5644)
        
    ]
    
}

