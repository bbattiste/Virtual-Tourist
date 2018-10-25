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
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
//    you can customize the UICollectionViewCell like this for placeholder
//
//    import UIKit
//
//    class PhotoViewCell: UICollectionViewCell {
//        static let identifier = "PhotoViewCell"
//
//        var imageUrl: String = ""
//        @IBOutlet weak var imageView: UIImageView!
//        @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
//
//    }

    
    
    
//------------------------------------------------------------------------------
// MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicatorMap: UIActivityIndicatorView!
    
//------------------------------------------------------------------------------
// MARK: Vars/Lets
    
    var pins: [Pin] = []
    let client = FlickrClient()
    var dataController: DataController!

//------------------------------------------------------------------------------
// MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorMap.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicatorMap.startAnimating()
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
        }
        addPinsToMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerMapOnLocation(location: CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "InitialLatitude"), longitude: UserDefaults.standard.double(forKey: "InitialLongitude")), map: mapView, size: 2350000)
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        self.activityIndicatorMap.stopAnimating()
    }

//------------------------------------------------------------------------------
// MARK: Actions
    
    @IBAction func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began {
            
            // Create coordinate from touchpoint
            let touchPoint = gesture.location(in: mapView)
            let newCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            // Guard from being too high/low on map that when recentering map, it won't crash
            guard (newCoordinate.latitude > Constants.Flickr.SearchLatRange.0) && (newCoordinate.latitude < Constants.Flickr.SearchLatRange.1) else {
                print("Pin drop out of range")
                return
            }
            
            // Save pin data
            let pinToSave = Pin(context: dataController.viewContext)
            pinToSave.latitude = newCoordinate.latitude
            pinToSave.longitude = newCoordinate.longitude
            try? dataController.viewContext.save()
            
            // Create Annotation
            let pinAnnotation = PinObject(pinData: pinToSave, coordinate: newCoordinate)
            self.mapView.addAnnotation(pinAnnotation)
            
            // Save coordinates of pin tapped for UserDefault
            UserDefaults.standard.set(newCoordinate.latitude, forKey: "InitialLatitude")
            UserDefaults.standard.set(newCoordinate.longitude, forKey: "InitialLongitude")
            UserDefaults.standard.synchronize()
        }
    }
    
//------------------------------------------------------------------------------
// MARK: Functions
    
    // push PhotoViewController when pin tapped
    func mapView(_ mapView: MKMapView, didSelect: MKAnnotationView) {
        
        // Save coordinates of pin tapped for UserDefault
        UserDefaults.standard.set(didSelect.annotation!.coordinate.latitude, forKey: "InitialLatitude")
        UserDefaults.standard.set(didSelect.annotation!.coordinate.longitude, forKey: "InitialLongitude")
        UserDefaults.standard.synchronize()
        
        // Create a instance of Destination photoViewController
        let goToPhotoViewController = storyboard?.instantiateViewController(withIdentifier: "PhotoViewControllerStoryBoard") as! PhotoViewController
        
        guard let annotation = didSelect.annotation as? PinObject else {
            fatalError("Incorrect Annotation Object")
        }
        
        // pass vars/lets to destination photoViewController
        let selectedMapPin = annotation.pinData
        
        goToPhotoViewController.selectedPhotoPin = selectedMapPin
        goToPhotoViewController.dataController = self.dataController
        
        // Pass the created instance to navigation stack
        navigationController?.pushViewController(goToPhotoViewController, animated: true)
    }
    
    // For every pin in Pinarray, set annotation to map
    func addPinsToMap() {
        for pin in pins {
            let pinAnnotation = PinObject(pinData: pin, coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
            self.mapView.addAnnotation(pinAnnotation)
        }
    }
    
    // This changes changes the view of the pin
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
