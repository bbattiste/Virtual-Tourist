//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Bryan's Air on 9/13/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // center map around point when exiting view
        
    }
    
    @IBAction func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.ended {
            let touchPoint = gesture.location(in: mapView)
            let newCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

            let pin = PinObject(coordinate: newCoordinate)

            pin.coordinate = newCoordinate
            self.mapView.addAnnotation(pin)
        }
        
        // maybe create array of annotations
    }
    
    func mapView(_ mapView: MKMapView, didSelect: MKAnnotationView) {
        
        // Grab coordinates of pin tapped
        GlobalVariables.LocationCoordinate = didSelect.annotation!.coordinate
        
        // Create a instance of Destination photoViewController
        let goToPhotoViewController = storyboard?.instantiateViewController(withIdentifier: "PhotoViewControllerStoryBoard") as! PhotoViewController
        
        // Pass the created instance to current navigation stack
        present(goToPhotoViewController, animated: true, completion: nil)
    }
    
    // This changes changes the view of the pin and mediaURL
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

}
