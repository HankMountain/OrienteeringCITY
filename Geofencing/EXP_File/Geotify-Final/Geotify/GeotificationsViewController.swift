/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit
import CoreLocation

struct PreferencesKeys {
  static let savedItems = "savedItems"
}

class GeotificationsViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  
  var geotifications: [Geotification] = []
  var locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    super.viewDidLoad()
    // 1
    locationManager.delegate = self
    // 2
    locationManager.requestAlwaysAuthorization()
    // 3
    loadAllGeotifications()
  }
  
  
  /////
  ///////Hank_modify_20160927
  /////
  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "addGeotification" {
      
      /////
      ///////Hank_modify_20160927
      /////
      
      let navigationController = segue.destinationViewController as! UINavigationController
//      let navigationController = segue.destination as! UINavigationController
      
      let vc = navigationController.viewControllers.first as! AddGeotificationViewController
      vc.delegate = self
    }
  }
  
  // MARK: Loading and saving functions
  func loadAllGeotifications() {
    geotifications = []
    
    /////
    ///////Hank_modify_20160927
    /////
    
    guard let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(PreferencesKeys.savedItems) else { return }
    for savedItem in savedItems {
      
      /////
      ///////Hank_modify_20160927
      /////
      
      guard let geotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geotification else { continue }
  
//      guard let geotification = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? Geotification else { continue }
      add(geotification)
    }
  }
  
  
  func saveAllGeotifications() {
    var items: [NSData] = []
    for geotification in geotifications {
      
      /////
      ///////Hank_modify_20160927
      /////
      
      let item = NSKeyedArchiver.archivedDataWithRootObject(geotification)
      
//      let item = NSKeyedArchiver.archivedData(withRootObject: geotification)
      items.append(item)
    }
    
    /////
    ///////Hank_modify_20160927
    /////
    
    NSUserDefaults.standardUserDefaults().setObject(items, forKey: PreferencesKeys.savedItems)
    
//    NSUserDefaults.standardUserDefaults().set(items, forKey: PreferencesKeys.savedItems)
  }
  
  // MARK: Functions that update the model/associated views with geotification changes
  func add(geotification: Geotification) {
    geotifications.append(geotification)
    mapView.addAnnotation(geotification)
    addRadiusOverlay(forGeotification: geotification)
    updateGeotificationsCount()
  }
  

  func remove(geotification: Geotification) {
    
    /////
    ///////Hank_modify_20160927
    /////
    
    if let indexInArray = geotifications.indexOf(geotification){
      geotifications.removeAtIndex(indexInArray)
    }
    
    
//    if let indexInArray = geotifications.index(of: geotification) {
//      geotifications.remove(at: indexInArray)
//    }
    
    mapView.removeAnnotation(geotification)
    removeRadiusOverlay(forGeotification: geotification)
    updateGeotificationsCount()
  }
  
  func updateGeotificationsCount() {
    title = "Geotifications (\(geotifications.count))"
    navigationItem.rightBarButtonItem?.enabled = (geotifications.count < 20)
  }
  
  // MARK: Map overlay functions
  func addRadiusOverlay(forGeotification geotification: Geotification) {
    
    /////
    ///////Hank_modify_20160927
    /////
    
    mapView?.addOverlay(MKCircle(centerCoordinate: geotification.coordinate, radius: geotification.radius))
    
//    mapView?.add(MKCircle(center: geotification.coordinate, radius: geotification.radius))
  }
  
  func removeRadiusOverlay(forGeotification geotification: Geotification) {
    // Find exactly one overlay which has the same coordinates & radius to remove
    guard let overlays = mapView?.overlays else { return }
    for overlay in overlays {
      guard let circleOverlay = overlay as? MKCircle else { continue }
      let coord = circleOverlay.coordinate
      if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
        
        mapView?.removeOverlay(circleOverlay)
        
//        mapView?.remove(circleOverlay)
        break
      }
    }
  }
  
  // MARK: Other mapview functions
  @IBAction func zoomToCurrentLocation(sender: AnyObject) {
    mapView.zoomToUserLocation()
  }
  
  func region(withGeotification geotification: Geotification) -> CLCircularRegion {
    // 1
    let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
    // 2
    region.notifyOnEntry = (geotification.eventType == .onEntry)
    region.notifyOnExit = !region.notifyOnEntry
    return region
  }
  
  func startMonitoring(geotification: Geotification) {
    // 1
    
    
    /////
    ///////Hank_modify_20160927
    /////
    
    
    if CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion.self) {
      showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
      return
    }
    
    
//    if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
//      showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
//      return
//    }
    
    
    // 2
    
    /////
    ///////Hank_modify_20160927
    /////
    
    if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
      showAlert(withTitle:"Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
    }
    
    
//    if CLLocationManager.authorizationStatus() != .authorizedAlways {
//      showAlert(withTitle:"Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
//    }
    
    // 3
    let region = self.region(withGeotification: geotification)
    // 4
    
    /////
    ///////Hank_modify_20160927
    /////
    
    locationManager.startMonitoringForRegion(region)
    
//    locationManager.startMonitoring(for: region)
  }
  
  func stopMonitoring(geotification: Geotification) {
   for region in locationManager.monitoredRegions {
    
    /////
    ///////Hank_modify_20160927
    /////
    
      guard let circularRegion = region as? CLCircularRegion where circularRegion.identifier == geotification.identifier else { continue }
    /////
    ///////Hank_modify_20160927
    /////
    
    locationManager.stopMonitoringForRegion(circularRegion)
    
//      locationManager.stopMonitoring(for: circularRegion)
    }
  }
}

// MARK: AddGeotificationViewControllerDelegate
extension GeotificationsViewController: AddGeotificationsViewControllerDelegate {
  
  func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType) {
    
    /////
    ///////Hank_modify_20160927
    /////
    
    controller.dismissViewControllerAnimated(true, completion: nil)
    
//    controller.dismiss(animated: true, completion: nil)
    // 1
    let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
    let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
    add(geotification)
    // 2
    startMonitoring(geotification)
    saveAllGeotifications()
  }

}

// MARK: - Location Manager Delegate
extension GeotificationsViewController: CLLocationManagerDelegate {
  
  func locationManager(manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    /////
    ///////Hank_modify_20160927
    /////
    
    mapView.showsUserLocation = status == .AuthorizedAlways
    
//    mapView.showsUserLocation = status == .authorizedAlways
  }
  
  func locationManager(manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: NSError) {
    print("Monitoring failed for region with identifier: \(region!.identifier)")
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Location Manager failed with the following error: \(error)")
  }

}

// MARK: - MapView Delegate
extension GeotificationsViewController: MKMapViewDelegate {
  
  func mapView(mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "myGeotification"
    if annotation is Geotification {
      
      /////
      ///////Hank_modify_20160927
      /////
      
      var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
      
//      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.canShowCallout = true
        
        /////
        ///////Hank_modify_20160927
        /////
        
        let removeButton = UIButton(type: .Custom)
        removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        
        /////
        ///////Hank_modify_20160927
        /////
        
        removeButton.setImage(UIImage(named: "DeleteGeotification")!, forState: .Normal)
        annotationView?.leftCalloutAccessoryView = removeButton
      } else {
        annotationView?.annotation = annotation
      }
      return annotationView
    }
    return nil
  }
  
  
  func mapView(mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKCircle {
      let circleRenderer = MKCircleRenderer(overlay: overlay)
      circleRenderer.lineWidth = 1.0
      
      /////
      ///////Hank_modify_20160927
      /////
      
      circleRenderer.strokeColor = .purpleColor()
      
      /////
      ///////Hank_modify_20160927
      /////
      
      circleRenderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.4)
      
//      circleRenderer.fillColor = UIColor.purpleColor().withAlphaComponent(0.4)
      return circleRenderer
    }
    return MKOverlayRenderer(overlay: overlay)
  }
  
  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    // Delete geotification
    let geotification = view.annotation as! Geotification
    
    /////
    ///////Hank_modify_20160927
    /////
    
    remove(geotification)
    
//    remove(geotification: geotification)
    saveAllGeotifications()
  }
  
}
