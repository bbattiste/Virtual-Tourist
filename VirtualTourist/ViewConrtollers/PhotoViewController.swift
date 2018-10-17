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
    
    //@IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    
    //TODO: button that initiates the download of a new album, replacing the images in the photo album with a new set from Flickr.
    
    // MARK: Vars/Lets
    let pinLocation = GlobalVariables.LocationCoordinate
    let client = FlickrClient()
    var photos = GlobalVariables.globalPhotosArray
    var dataController: DataController!
    var selectedPhotoPin: Pin!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorPhoto.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicatorPhoto.startAnimating()
        centerMapOnLocation(location: self.pinLocation, map: self.mapView, size: 50000)
        self.createAnnotation()
        
        
        //TODO: if new location, download Json, call completion handler to figure out how many cells, activity indicators, photos... otherwise displays saved photos
        //self.client.getPhotos()
        
        client.getPhotos() { (success, uRLResultLevel1, error) in
            if success {
                
                GlobalVariables.globalURLArray = uRLResultLevel1
                
                // save imageUrlStrings from array
                for uRLString in uRLResultLevel1 {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.uRL = uRLString
                    
                    let imageURL = URL(string: uRLString)
                    let imageAsData = try? Data(contentsOf: imageURL!)
                    photo.image = imageAsData
                    
                    self.selectedPhotoPin.addToPhotos(photo)
                    try? self.dataController.viewContext.save()
                    print("photo Saved")
                    
                }
                
            // Fetch Photos
                let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
                let predicate = NSPredicate(format: "pin == %@", self.selectedPhotoPin)
                fetchRequest.predicate = predicate
                
                //fetchedResultsController needs sorting to work properly
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                
//                if let result = try? self.dataController.viewContext.fetch(fetchRequest) {
//                    self.photos = result
//                }
                
                self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
                self.fetchedResultsController.delegate = self
                do {
                    try self.fetchedResultsController.performFetch()
                    print("fetchPerformed")
                } catch {
                    fatalError("The fetch could not be performed: \(error.localizedDescription)")
                }
                
                

//                let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
//                if let result = try? dataController.viewContext.fetch(fetchRequest) {
//                    pins = result
//                }
//                addPinsToMap()
                
                performUIUpdatesOnMain {
                    self.photoCollectionView.reloadData()
                    self.activityIndicatorPhoto.stopAnimating()
                    //self.activityIndicatorMap.stopAnimating()
                }
            } else {
                performUIUpdatesOnMain {
                    print(error!)
                    self.activityIndicatorPhoto.stopAnimating()
                    //self.activityIndicatorMap.stopAnimating()
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        print("photos end view = \(self.photos.count)")
        print("GlobalVariables.globalURLArray end view = \(GlobalVariables.globalURLArray.count)")
        GlobalVariables.globalURLArray = []
        print("GlobalVariables.globalURLArray reset = \(GlobalVariables.globalURLArray.count)")
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
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            //TODO:  number of pics returned.count
            print("numberOfItemsInSection = \(GlobalVariables.globalURLArray.count)")
            return GlobalVariables.globalURLArray.count
        }
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            print("cellForItemAt")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
            //print("fetchedResultsController.object = \(fetchedResultsController.object)")
            let photoForCell = fetchedResultsController.object(at: indexPath)
            print(photoForCell)
            // Set the image
            cell.imageView.image = UIImage(data: photoForCell.image!)
    
            return cell
        }
    
    // TODO: Delete photos: lesson 4.8
//        override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
//      //TODO: Tapping the image removes it from the photo album, the booth in the collection view, and Core Data.
//
//            let detailController = self.storyboard!.instantiateViewController(withIdentifier: "VillainDetailViewController") as! VillainDetailViewController
//            detailController.villain = self.allVillains[(indexPath as NSIndexPath).row]
//            self.navigationController!.pushViewController(detailController, animated: true)
//
//        }
    
}
