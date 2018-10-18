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
import CoreData

class PhotoViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicatorPhoto: UIActivityIndicatorView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var missingImagesLabel: UILabel!
    
    
    //TODO: button that initiates the download of a new album, replacing the images in the photo album with a new set from Flickr.
    
    // MARK: Vars/Lets
    let pinLocation = GlobalVariables.LocationCoordinate
    let client = FlickrClient()
    var photos = GlobalVariables.globalPhotosArray
    var dataController: DataController!
    var selectedPhotoPin: Pin!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var indexOfCollectionView = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial setup
        missingImagesLabel.isHidden = true
        activityIndicatorPhoto.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicatorPhoto.startAnimating()
        centerMapOnLocation(location: self.pinLocation, map: self.mapView, size: 50000)
        self.createAnnotation()
        
        
        //TODO: displays saved photos, otherwise download Json, call completion handler to figure out how many cells, activity indicators, photos...
        
        pullSavedPhotos()
        if let isSavedPhotos = fetchedResultsController.sections {
            print("Has Saved photos to use")
            print(isSavedPhotos.count)
            print(fetchedResultsController.sections as Any)
        } else{
            print("is not any saved photos")
        }
        
        
        client.getPhotos() { (success, uRLResultLevel1, error) in
            if success {
                
                performUIUpdatesOnMain {
                    self.missingImagesLabel.isHidden = true
                }
                GlobalVariables.globalURLArray = uRLResultLevel1
                
                // Check for images to make missingImagesLabel visible or hidden
                
                
                // save imageUrlStrings from array
                for uRLString in uRLResultLevel1 {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.uRL = uRLString
                    
                    let imageURL = URL(string: uRLString)
                    let imageAsData = try? Data(contentsOf: imageURL!)
                    photo.image = imageAsData
                    
                    self.selectedPhotoPin.addToPhotos(photo)
                    try? self.dataController.viewContext.save()
                }
                
                self.pullSavedPhotos()
                
                performUIUpdatesOnMain {
                    self.photoCollectionView.reloadData()
                    self.activityIndicatorPhoto.stopAnimating()
                    //self.activityIndicatorMap.stopAnimating()
                }
            } else {
                performUIUpdatesOnMain {
                    print(error!)
                    self.activityIndicatorPhoto.stopAnimating()
                    self.missingImagesLabel.isHidden = false
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        GlobalVariables.globalURLArray = []
    }
    
    // Fetch Photos using fetchedRequest and fetchController
    func pullSavedPhotos() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.selectedPhotoPin)
        fetchRequest.predicate = predicate
        
        //fetchedResultsController needs sorting to work properly
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
            print("fetchPerformed")
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    func createAnnotation() {
        let pin = PinObject(coordinate: pinLocation)
        pin.coordinate = pinLocation
        self.mapView.addAnnotation(pin)
    }
}

extension PhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Collection View Data Source
    //TODO: Place holder images until photos are downloaded, displayed as soon as possible
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let photoForCell = fetchedResultsController.object(at: indexPath)
        // Set the image
        cell.imageView.image = UIImage(data: photoForCell.image!)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        print("didSelectItemAt called")
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? self.dataController.viewContext.save()
    }
    
    func deletePhotoData(at indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
    }
}
