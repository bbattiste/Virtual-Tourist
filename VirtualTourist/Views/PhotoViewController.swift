//
//  PhotoViewController.swift
//  VirtualTourist
//
//  Created by Bryan's Air on 9/13/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class PhotoViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    // MARK: Vars/Lets
    let pinLocation = GlobalVariables.LocationCoordinate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapOnLocation(location: pinLocation, map: mapView, size: 50000)
        createAnnotation()
    }

    func createAnnotation() {
        let pin = PinObject(coordinate: pinLocation)
        pin.coordinate = pinLocation
        self.mapView.addAnnotation(pin)
    }

}
