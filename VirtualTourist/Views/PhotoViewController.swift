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
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    //TODO: button that initiates the download of a new album, replacing the images in the photo album with a new set from Flickr.
    
    // MARK: Vars/Lets
    let pinLocation = GlobalVariables.LocationCoordinate
    let client = FlickrClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapOnLocation(location: pinLocation, map: mapView, size: 50000)
        createAnnotation()
        //TODO: if new location, download photos, otherwise displays assigned photos
        client.getPhotos()
    }

    func createAnnotation() {
        let pin = PinObject(coordinate: pinLocation)
        pin.coordinate = pinLocation
        self.mapView.addAnnotation(pin)
    }
    
    // MARK: Collection View Data Source
    //TODO: Place holder images until photos are downloaded, displayed as soon as possible
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        //TODO:  number of pics returned.count
//        return 1
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
//        let photosInCell = self.photos[(indexPath as NSIndexPath).row]
//
//        // Set the image
//        cell.villainImageView?.image = UIImage(named: villain.imageName)
//        //cell.schemeLabel.text = "Scheme: \(villain.evilScheme)"
//
//        return cell
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
    //  //TODO: Tapping the image removes it from the photo album, the booth in the collection view, and Core Data.
    
//        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "VillainDetailViewController") as! VillainDetailViewController
//        detailController.villain = self.allVillains[(indexPath as NSIndexPath).row]
//        self.navigationController!.pushViewController(detailController, animated: true)
//
//    }
}

extension FlickrClient {
    
}
