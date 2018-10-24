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

class PhotoViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicatorPhoto: UIActivityIndicatorView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var missingImagesLabel: UILabel!
    
    // MARK: Vars/Lets
    let pinLocation = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "InitialLatitude"), longitude: UserDefaults.standard.double(forKey: "InitialLongitude"))
    let client = FlickrClient()
    var dataController: DataController!
    var selectedPhotoPin: Pin!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var indexOfCollectionView = 0
    
    // MARK: LIfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial setup
        missingImagesLabel.isHidden = true
        activityIndicatorPhoto.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicatorPhoto.startAnimating()
        
        // Center map and create pin
        centerMapOnLocation(location: pinLocation, map: mapView, size: 50000)
        createAnnotation()
        
        // Fetch, Check if saved Photos, else get from client
        pullSavedPhotos()
        checkIfPhotos()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //TODO: button that initiates the download of a new album, replacing the images in the photo album with a new set from Flickr.
    // MARK: Actions
    @IBAction func getNewCollection(_ sender: Any) {
        deleteSavedPhotos()
        getphotosFromClient()
    }

    // MARK: Functions
    
    // if saved photos proceed, else get them from client
    func checkIfPhotos() {
        if selectedPhotoPin.photos?.count != 0 {
            activityIndicatorPhoto.stopAnimating()
            print("test 1")
        } else {
            print("test 2")
            getphotosFromClient()
        }
    }
    
    func getphotosFromClient() {
        client.getPhotos() { (success, uRLResultLevel1, error) in
            if success {
                
                performUIUpdatesOnMain {
                    self.missingImagesLabel.isHidden = true
                }
                
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
                
                performUIUpdatesOnMain {
                    self.activityIndicatorPhoto.stopAnimating()
                }
                return
            } else {
                performUIUpdatesOnMain {
                    print(error!)
                    self.activityIndicatorPhoto.stopAnimating()
                    self.missingImagesLabel.isHidden = false
                }
            }
        }
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
    
    func deleteSavedPhotos() {
        activityIndicatorPhoto.startAnimating()
        for cell in photoCollectionView.visibleCells {
            if let cell = cell as? PhotoCollectionViewCell {
                cell.activityIndicatorCollectionViewCell.startAnimating()
                cell.imageView.image = UIImage(named: "world")
            }
        }
        
        if let photosToDelete = fetchedResultsController.fetchedObjects {
            for photo in photosToDelete {
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("Will Not Delete")
                }
            }
        }
    }
        
    func createAnnotation() {
        let pin = PinObject(pinData: selectedPhotoPin, coordinate: pinLocation)
        pin.coordinate = pinLocation
        self.mapView.addAnnotation(pin)
    }
}

//------------------------------------------------------------------------------
// MARK: UICollectionView dataSource, delegate

extension PhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //TODO: Place holder images until photos are downloaded, displayed as soon as possible
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        // Set the image
        let photoForCell = fetchedResultsController.object(at: indexPath)
        cell.imageView.image = UIImage(data: photoForCell.image!)
        cell.activityIndicatorCollectionViewCell.stopAnimating()
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

//------------------------------------------------------------------------------
// MARK: NSFetchedResultsControllerDelegate

extension PhotoViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            photoCollectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            photoCollectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            photoCollectionView.reloadItems(at: [indexPath!])
            break
        case .move:
            photoCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: photoCollectionView.insertSections(indexSet)
        case .delete: photoCollectionView.deleteSections(indexSet)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }

    
}

