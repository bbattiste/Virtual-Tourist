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
    @IBOutlet weak var FlowLayout: UICollectionViewFlowLayout!
    
    
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

    func getPhotos(_ sender: AnyObject) {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        //displayImagesFromFlickr(methodParameters as [String:AnyObject])
    }
    
    private func bboxString() -> String {
        // ensure bbox is bounded by minimum and maximums, has max and mins if wanting to add an enter in own coordinates feature
        let latitude = pinLocation.latitude
        let longitude = pinLocation.longitude
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    // MARK: Flickr API
    
//    private func displayImagesFromFlickr(_ methodParameters: [String: AnyObject]) {
//
//        // create session and request
//        let session = URLSession.shared
//        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
//        print(request)
//
//        // create network request
//        let task = session.dataTask(with: request) { (data, response, error) in
//
//            // if an error occurs, print it and re-enable the UI
//            func displayError(_ error: String) {
//                print(error)
//            }
//
//            /* GUARD: Was there an error? */
//            guard (error == nil) else {
//                displayError("There was an error with your request: \(String(describing: error))")
//                return
//            }
//
//            /* GUARD: Did we get a successful 2XX response? */
//            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
//                displayError("Your request returned a status code other than 2xx!")
//                return
//            }
//
//            /* GUARD: Was there any data returned? */
//            guard let data = data else {
//                displayError("No data was returned by the request!")
//                return
//            }
//
//            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                displayError("Could not parse the data as JSON: '\(data)'")
//                return
//            }
//
//            /* GUARD: Did Flickr return an error (stat != ok)? */
//            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
//                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
//                return
//            }
//            print("***parsedResult: \(parsedResult)")
//            /* GUARD: Is "photos" key in our result? */
//            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
//                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
//                return
//            }
//            print("***photosDictionary: \(photosDictionary)")
//
//            /* GUARD: Is "pages" key in the photosDictionary? */
//            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
//                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
//                return
//            }
//
//            // pick a random page!
//            let pageLimit = min(totalPages, 40)
//            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
//            self.displayImagesFromFlickr(methodParameters, withPageNumber: randomPage)
//        }
//
//        // start the task!
//        task.resume()
//    }
//
//    // FIX: For Swift 3, variable parameters are being depreciated. Instead, create a copy of the parameter inside the function.
//
//    private func displayImagesFromFlickr(_ methodParameters: [String: AnyObject], withPageNumber: Int) {
//
//        // add the page to the method's parameters as new var
//        var methodParametersWithPageNumber = methodParameters
//        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
//
//        // create session and request
//        let session = URLSession.shared
//        let request = URLRequest(url: flickrURLFromParameters(methodParametersWithPageNumber))
//
//        // create network request
//        let task = session.dataTask(with: request) { (data, response, error) in
//
//            // if an error occurs, print it and re-enable the UI
//            func displayError(_ error: String) {
//                print(error)
//            }
//
//            /* GUARD: Was there an error? */
//            guard (error == nil) else {
//                displayError("There was an error with your request: \(String(describing: error))")
//                return
//            }
//
//            /* GUARD: Did we get a successful 2XX response? */
//            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
//                displayError("Your request returned a status code other than 2xx!")
//                return
//            }
//
//            /* GUARD: Was there any data returned? */
//            guard let data = data else {
//                displayError("No data was returned by the request!")
//                return
//            }
//
//            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                displayError("Could not parse the data as JSON: '\(data)'")
//                return
//            }
//
//            /* GUARD: Did Flickr return an error (stat != ok)? */
//            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
//                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
//                return
//            }
//
//            /* GUARD: Is the "photos" key in our result? */
//            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
//                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
//                return
//            }
//
//            /* GUARD: Is the "photo" key in photosDictionary? */
//            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
//                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
//                return
//            }
//
//            if photosArray.count == 0 {
//                displayError("No Photos Found. Search Again.")
//                return
//            } else {
//                // TODO: while (pics available) and for (pics with not same index as already used pics) statements
//                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
//                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
//                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
//
//                /* GUARD: Does our photo have a key for 'url_m'? */
//                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
//                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
//                    return
//                }
//
//                //TODO: Do collection view instead of UIImage
//                // if an image exists at the url, set the image and title
//                let imageURL = URL(string: imageUrlString)
//                if let imageData = try? Data(contentsOf: imageURL!) {
//                    performUIUpdatesOnMain {
//                        self.setUIEnabled(true)
//                        self.photoImageView.image = UIImage(data: imageData)
//                        self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
//                    }
//                } else {
//                    displayError("Image does not exist at \(imageURL)")
//                }
//            }
//        }
//
//        // start the task!
//        task.resume()
//    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

}
