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
    
    @IBOutlet weak var mapView: MKMapView!
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
        centerMapOnLocation(location: self.pinLocation, map: self.mapView, size: 50000)
        self.createAnnotation()
        
        
        //TODO: if new location, download Json, call completion handler to figure out how many cells, activity indicators, photos... otherwise displays saved photos
        //self.client.getPhotos()
        
//        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
//        let predicate = NSPredicate(format: "pin == %@", selectedPhotoPin)
//        fetchRequest.predicate = predicate
//
//        if let result = try? dataController.viewContext.fetch(fetchRequest) {
//            photos = result
//        }
        
        client.getPhotos() { (success, uRLResultLevel1, error) in
            if success {
                
                performUIUpdatesOnMain {
                    self.photoCollectionView.reloadData()
                    //self.activityIndicatorMap.stopAnimating()
                }
                GlobalVariables.globalURLArray = uRLResultLevel1
                
                // save imageUrlStrings from array
                for uRLString in uRLResultLevel1 {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.uRL = uRLString
                    
                    let imageURL = NSURL(string: uRLString)
                    let imageAsData = try? Data(contentsOf: imageURL! as URL)
                    photo.image = imageAsData
                    
                    print(self.selectedPhotoPin)
                    print(photo)
                    self.selectedPhotoPin.addToPhotos(photo)
                    try? self.dataController.viewContext.save()
                    print("photo Saved")
                    
                }
                
                
                performUIUpdatesOnMain {
                    self.photoCollectionView.reloadData()
                    //self.activityIndicatorMap.stopAnimating()
                }
            } else {
                performUIUpdatesOnMain {
                    print(error!)
                    //self.activityIndicatorMap.stopAnimating()
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
//            let photosInCell = GlobalVariables.globalPhotosArray[(indexPath as NSIndexPath).row]
    
            // Set the image
            // TODO: cell.imageView?.image = photosInCell
    
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
