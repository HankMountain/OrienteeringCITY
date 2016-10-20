//
//  LocationCoreDataModel+CoreDataProperties.swift
//  OrienteeringCITY
//
//  Created by Hank on 2016/10/16.
//  Copyright © 2016年 Hank. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LocationCoreDataModel {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var timestamp: NSDate?
    @NSManaged var run: RunCoreDataModel?

}
