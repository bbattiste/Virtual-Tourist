//
//  GlobalFunctions.swift
//  VirtualTourist
//
//  Created by Bryan's Air on 10/1/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import Foundation
import MapKit

// Configure zoom on pinLocation
func centerMapOnLocation(location: CLLocationCoordinate2D, region: MKMapView) {
    let regionRadius: CLLocationDistance = 2250000
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
                                                              regionRadius * 2.0, regionRadius * 2.0)
    region.setRegion(coordinateRegion, animated: true)
}
