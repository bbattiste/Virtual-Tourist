//
//  PinObject.swift
//  VirtualTourist
//
//  Created by Bryan's Air on 9/24/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class PinObject: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pin: Pin?
    var context: NSManagedObjectContext
    
    init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext){
        self.coordinate = coordinate
        self.context = context
    }
}
