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
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    
    //TODO: button that initiates the download of a new album, replacing the images in the photo album with a new set from Flickr.
    
    // MARK: Vars/Lets
    let pinLocation = GlobalVariables.LocationCoordinate
    let client = FlickrClient()
    var photos = GlobalVariables.globalPhotosArray
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("test1")
        centerMapOnLocation(location: self.pinLocation, map: self.mapView, size: 50000)
        print("test2")
        self.createAnnotation()
        print("test3")
        //TODO: if new location, download photos, otherwise displays assigned photos
        //self.client.getPhotos()
        client.getPhotos() { (success, error) in
            if success {
                self.photoCollectionView.reloadData()
                print("test3.5")
            } else {
                print(error!)
            }
        }
        print("test4")
        self.photoCollectionView.reloadData()
        print("test5 photos begin view = \(self.photos)")
        print("test6 GlobalVariables.globalPhotosArray begin view= \(GlobalVariables.globalPhotosArray)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("photos end view = \(self.photos.count)")
        print("GlobalVariables.globalPhotosArray end view= \(GlobalVariables.globalPhotosArray.count)")
    }

    func createAnnotation() {
        let pin = PinObject(coordinate: pinLocation, context: dataController.viewContext)
        pin.coordinate = pinLocation
        self.mapView.addAnnotation(pin)
    }
}

extension PhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Collection View Data Source
    //TODO: Place holder images until photos are downloaded, displayed as soon as possible
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            //TODO:  number of pics returned.count
            print("numberOfItemsInSection = \(GlobalVariables.globalPhotosArray.count)")
            return GlobalVariables.globalPhotosArray.count
        }
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            print("cellForItemAt")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
            let photosInCell = GlobalVariables.globalPhotosArray[(indexPath as NSIndexPath).row]
    
            // Set the image
            cell.imageView?.image = photosInCell
    
            return cell
        }
    
//        override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
//      //TODO: Tapping the image removes it from the photo album, the booth in the collection view, and Core Data.
//
//            let detailController = self.storyboard!.instantiateViewController(withIdentifier: "VillainDetailViewController") as! VillainDetailViewController
//            detailController.villain = self.allVillains[(indexPath as NSIndexPath).row]
//            self.navigationController!.pushViewController(detailController, animated: true)
//
//        }
    
}
