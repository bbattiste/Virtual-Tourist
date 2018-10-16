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
func centerMapOnLocation(location: CLLocationCoordinate2D, map: MKMapView, size: Double) {
    let regionRadius: CLLocationDistance = size
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
                                                              regionRadius * 2.0, regionRadius * 2.0)
    map.setRegion(coordinateRegion, animated: true)
}

//func convertURLToData(uRLString: String, completionHandler: @escaping (_ success: Bool, _ error: String?, _ imageData: Data) -> Void) {
//    let imageURL = NSURL(string: uRLString)
//    let imageAsData = try? Data(contentsOf: imageURL! as URL)
//    completionHandler(true, nil, imageAsData!)
//}

