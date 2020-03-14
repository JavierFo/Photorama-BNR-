//
//  PhotoStore.swift
//  Photorama
//
//  Created by Javier Ferrer on 12/31/19.
//  Copyright © 2019 Javier Ferrer. All rights reserved.
//

import UIKit

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

class PhotoStore {
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchInterestingPhotos(completion: @escaping (PhotosResult) -> Void) {
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
    //            if let jsonData = data {
    ////                if let jsonString = String(data: jsonData, encoding: .utf8) {
    ////                        print(jsonString)
    ////                        }
    //                do {
    //                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
    //                    print(jsonObject)
    //                } catch let error {
    //                    print("Error creating JSON object: \(error)")
    //                }
    //
    //            } else if let requestError = error {
    //
    //                print("Error fetching interesting photos: \(requestError)")
    //            } else {
    //                print("Unexpected error with the request")
    //                }
            
            let result = self.processPhotosRequest(data: data, error: error)
            
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
                let allHeaderFields:[AnyHashable : Any] = response.allHeaderFields
                print("All headers: \(allHeaderFields)")
            }
            
            OperationQueue.main.addOperation {
                completion(result)
                
            }
        }
        task.resume()
    }
    
    private func processPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return FlickrAPI.photos(fromJSON: jsonData)
    }
    
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            
            if let response = response as? HTTPURLResponse {
                print("Response IMAGE HTTP Status code: \(response.statusCode)")
                
                let allHeaderFields:[AnyHashable : Any] = response.allHeaderFields
                print("All headers: \(allHeaderFields)")
            }
            
            OperationQueue.main.addOperation {
                completion(result)
                print(result)
            }
        }
        task.resume()
    }
    
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
               
                // Couldn't create an image
                if data == nil {
                       return .failure(error!)
                   } else {
                       return .failure(PhotoError.imageCreationError)
                   }
                }
        
        return .success(image)
    }
    
}
