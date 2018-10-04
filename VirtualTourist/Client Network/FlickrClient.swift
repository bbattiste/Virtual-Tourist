//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Bryan's Air on 10/2/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient {
    
    let pinLocation = GlobalVariables.LocationCoordinate
    
    // MARK: Network to get photos from Flickr
    func getPhotos(completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
//        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
        displayImagesFromFlickr(methodParameters as [String:AnyObject])
        completionHandler(true, nil)
//            DispatchQueue.main.async(execute: { () -> Void in
//                handler(img)
//            }
//
//            return
//        }
    }
    ////
    // MARK: Download Big Image
    
    // This method downloads and image in the background once it's
    // finished, it runs the closure it receives as a parameter.
    // This closure is called a completion handler
    // Go download the image, and once you're done, do _this_ (the completion handler)
//    func withBigImage(completionHandler handler: @escaping (_ image: UIImage) -> Void){
//
//        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
//
//            // get the url
//            // get the NSData
//            // turn it into a UIImage
//            if let url = URL(string: BigImages.whale.rawValue), let imgData = try? Data(contentsOf: url), let img = UIImage(data: imgData) {
//                // run the completion block
//                // always in the main queue, just in case!
//                DispatchQueue.main.async(execute: { () -> Void in
//                    handler(img)
//                })
//            }
//        }
//    }
    ////
    
    private func bboxString() -> String {
        // ensure bbox is bounded by minimum and maximums, has max and mins if wanting to add enter in own coordinates feature
        let latitude = pinLocation.latitude
        let longitude = pinLocation.longitude
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    // MARK: Flickr API
    
    private func displayImagesFromFlickr(_ methodParameters: [String: AnyObject]) {
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            self.displayImagesFromFlickr(methodParameters, withPageNumber: randomPage)
        }
        
        // start the task!
        task.resume()
    }
    
    // FIX: For Swift 3, variable parameters are being depreciated. Instead, create a copy of the parameter inside the function.
    
    private func displayImagesFromFlickr(_ methodParameters: [String: AnyObject], withPageNumber: Int) {
        
        // add the page to the method's parameters as new var
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
        print("withPageNumber = \(withPageNumber)")
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParametersWithPageNumber))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                displayError("No Photos Found. Search Again.")
                return
            } else {
                
                var randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                print("randomPhotoIndex = \(randomPhotoIndex)")
                if randomPhotoIndex > 229 {
                    randomPhotoIndex = (randomPhotoIndex - 21)
                }
                
                // TODO: use 21 consecutive pics
                var photoNumberIndex = 0
                var photos = [UIImage]()
                let numberOfPhotosToShow = min(photosArray.count, 21)
                
                while photoNumberIndex != numberOfPhotosToShow {
                    
                    var photoDictionary = photosArray[randomPhotoIndex + photoNumberIndex] as [String: AnyObject]
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                        displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                        return
                    }
                    
                    let imageURL = URL(string: imageUrlString)
                    //print("imageURL = \(String(describing: imageURL))")
                    if let imageData = try? Data(contentsOf: imageURL!) {
                        photos.append(UIImage(data: imageData)!)
                    }
                    photoNumberIndex += 1
                }
                print("photos.count = \(photos.count)")
                GlobalVariables.globalPhotosArray = photos
                print("GlobalVariables.globalPhotosArray DURING TASK")
            }
            print("GlobalVariables.globalPhotosArray AFTER TASK ")
        }
        // start the task!
        print("GlobalVariables.globalPhotosArray ?START? TASK ")
        task.resume()
    }
    
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
