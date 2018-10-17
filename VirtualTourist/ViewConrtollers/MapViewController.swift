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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicatorMap: UIActivityIndicatorView!
    
    // MARK: Vars/Lets
    var pins: [Pin] = []
    let pinLocation = GlobalVariables.LocationCoordinate
    let client = FlickrClient()
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorMap.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicatorMap.startAnimating()
        centerMapOnLocation(location: pinLocation, map: mapView, size: 2350000)
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
        }
        addPinsToMap()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            self.activityIndicatorMap.stopAnimating()
        })

    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupFetchedResultsController()
//        centerMapOnLocation(location: pinLocation, map: mapView, size: 2350000)
//    }
//
//    fileprivate func setupFetchedResultsController() {
//        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
//
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
//        fetchedResultsController.delegate = self
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("The fetch could not be performed: \(error.localizedDescription)")
//        }
//    }
    
    @IBAction func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began {
            
            // Create coordinate from touchpoint
            let touchPoint = gesture.location(in: mapView)
            let newCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            // Create Annotation
            let pinAnnotation = PinObject(coordinate: newCoordinate)
            self.mapView.addAnnotation(pinAnnotation)
            print("placed pin")
            
            // Save pin data
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = newCoordinate.latitude
            pin.longitude = newCoordinate.longitude
            try? dataController.viewContext.save()
            print("Saved location to CoreData")
        }
    }
    
    func addPinsToMap() {
        for pin in pins {
            let pinAnnotation = PinObject(coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
            self.mapView.addAnnotation(pinAnnotation)
        }
    }
    
    // push PhotoViewController when pin tapped
    func mapView(_ mapView: MKMapView, didSelect: MKAnnotationView) {
        
        // Grab coordinates of pin tapped
        GlobalVariables.LocationCoordinate = didSelect.annotation!.coordinate
        
        // Create a instance of Destination photoViewController
        let goToPhotoViewController = storyboard?.instantiateViewController(withIdentifier: "PhotoViewControllerStoryBoard") as! PhotoViewController
        
        // pass vars/lets to destination photoViewController
        let selectedMapPin = Pin(context: dataController.viewContext)
        selectedMapPin.latitude = didSelect.annotation!.coordinate.latitude
        selectedMapPin.latitude = didSelect.annotation!.coordinate.longitude
        print(selectedMapPin)
        
        goToPhotoViewController.selectedPhotoPin = selectedMapPin
        goToPhotoViewController.dataController = self.dataController
        
        // Pass the created instance to current navigation stack
        navigationController?.pushViewController(goToPhotoViewController, animated: true)
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
