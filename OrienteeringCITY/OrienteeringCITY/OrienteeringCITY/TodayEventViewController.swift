//
//  TodayEventViewController.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/9/30.
//  Copyright © 2016年 Hank. All rights reserved.
//

import UIKit
import MapKit


protocol AddGeotificationsViewControllerDelegate {
    func addGeotificationViewController(controller: TodayEventViewController, didAddCoordinate coordinate: CLLocationCoordinate2D,radius: Double, identifier: String, note: String, eventType: EventType)
}

class TodayEventViewController: UIViewController {
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    //把資料丟給InProcess_1_ViewController的地方
    func onAdd(){
        //測試
        //25.0424777,121.5648794
        //Appworks School
        let coordinate = CLLocationCoordinate2D(latitude: 25.0424777, longitude: 121.5648794)
        let radius = 100.0
        let identifier = NSUUID().UUIDString
        let note = "Appworks School"
        
        print("BREAK_POINT : 座標圖\(coordinate)")
        print("BREAK_POINT : 半徑\(radius)")
        print("BREAK_POINT : 辨認標籤\(identifier)")
        print("BREAK_POINT : 標記\(note)")
        
        let eventType: EventType = .onEntry ; delegate?.addGeotificationViewController(self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note, eventType: eventType)
        
        print("BREAK_POINT : 確認eventType是否有被執行以及傳送資料過去In_Pocess_1_\(eventType)")
        
        
        
    }
    
 
}
