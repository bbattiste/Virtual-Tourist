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
    //var pin: Pin?
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}
