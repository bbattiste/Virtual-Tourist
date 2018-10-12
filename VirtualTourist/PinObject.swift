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
    var pinData: Pin!

    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}

//public var coordinate: CLLocationCoordinate2D {
//    let latDegrees = CLLocationDegrees(latitude)
//    let longDegrees = CLLocationDegrees(longitude)
//    return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
//}
