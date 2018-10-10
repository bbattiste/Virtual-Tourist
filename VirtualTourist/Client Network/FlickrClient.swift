//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Bryan's Air on 10/2/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlickrClient {
    
    let pinLocation = GlobalVariables.LocationCoordinate
    var dataController: DataController!
    
    // MARK: Network to get photos from Flickr
    func getPhotos() {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        print("test4")
        getFlickrData(methodParameters as [String:AnyObject])
        print("test10")
    }
    
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
    
    private func getFlickrData(_ methodParameters: [String: AnyObject]) {
        
        // create session and request
        print("test 5")
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        print("test 5.1")
        let task = session.dataTask(with: request) { (data, response, error) in
            
            print("test 5.2")
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
            print("test 6")
            self.getRandomPageFlickrData(methodParameters, withPageNumber: randomPage) { (success, error) in
                if success {
                    // Proceed
                } else {
                    performUIUpdatesOnMain {
                        print(error!)
                        //self.activityIndicatorMap.stopAnimating()
                    }
                }
            }
            print("test9")
        }
        task.resume()
    }
    
    private func getRandomPageFlickrData(_ methodParameters: [String: AnyObject], withPageNumber: Int, completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        // add the page to the method's parameters as new var
        print("test7")
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
        print("withPageNumber = \(withPageNumber)")
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParametersWithPageNumber))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, "There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(false, "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(false, "No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandler(false, "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                completionHandler(false, "Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandler(false, "Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                completionHandler(false, "Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            /* GUARD: Check if any photos exist */
            guard photosArray.count == 0 else {
                completionHandler(false, "No Photos Found. Search Again.")
                return
            }
            
            var randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
            print("randomPhotoIndex = \(randomPhotoIndex)")
            
            // use 21 consecutive image URLs or number available
            if randomPhotoIndex > 21 {
                randomPhotoIndex = (randomPhotoIndex - 21)
            }
            if photosArray.count <= 21 {
                randomPhotoIndex = 0
            }
            let numberOfPhotosToShow = min(photosArray.count, 21)
            
            var photoNumberIndex = 0
            while photoNumberIndex != numberOfPhotosToShow {
                
                var photoDictionary = photosArray[randomPhotoIndex + photoNumberIndex] as [String: AnyObject]
                
                /* GUARD: Does our photo have a key for 'url_m'? */
                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    completionHandler(false, "Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                    return
                }
                
                // save imageUrlString
                let photo = Photo(context: self.dataController.viewContext)
                photo.uRL = imageUrlString
                try? self.dataController.viewContext.save()
                
                photoNumberIndex += 1
            }
            completionHandler(true, nil)
            print("test8")
            print("gathered URLS")
        }
        task.resume()
    }
    
    //                TODO: set images
    //                //var photos = [UIImage]()
    //                let imageURL = URL(string: imageUrlString)
    //                //print("imageURL = \(String(describing: imageURL))")
    //                if let imageData = try? Data(contentsOf: imageURL!) {
    //                    photos.append(UIImage(data: imageData)!)
    //                }

    
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

//// suggestion from mentor
//class NetworkClient: NSObject {
//
//    // shared session
//    var session = URLSession.shared
//
//    // MARK: Initializers
//
//    override init() {
//        super.init()
//    }
//
//
//    func doLogout(session: String, completion: @escaping (_ data: LogoutResponseModel?, _ error : String?) -> Void) {
//        makeRequest(.doLogout(session: session), type: LogoutResponseModel.self, completion: completion)
//    }
//
//    static let shared = NetworkClient()
//}

////and when you want to use a function in this class, you can do as below
//
//NetworkClient.shared.doLogin(email: email, password: password, completion: { (data, error) in
//.....
//})

// If you do choose to use a singleton it should be a private init so that there can be only one (accessed from .shared)

