//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Javier Ferrer on 12/18/19.
//  Copyright © 2019 Javier Ferrer. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
//    @IBOutlet var imageView: UIImageView!
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        store.fetchInterestingPhotos(){ (photosResult) -> Void in
                switch photosResult {
                case let .success(photos):
                    print("Successfully found \(photos.count) photos.\n")
//                    if let firstPhoto = photos.first {
//                        self.updateImageView(for: firstPhoto)
//                    }
                    self.photoDataSource.photos = photos
                case let .failure(error):
                    print("Error fetching interesting photos: \(error)")
                    self.photoDataSource.photos.removeAll()
                }
                self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
         let photo = photoDataSource.photos[indexPath.row]
            // Download the image data, which could take some time
            store.fetchImage(for: photo) { (result) -> Void in
                // The index path for the photo might have changed between the
                // time the request started and finished, so find the most
                // recent index path
                // (Note: You will have an error on the next line; you will fix it soon)
                guard let photoIndex = self.photoDataSource.photos.firstIndex(of: photo),
                    case let .success(image) = result else {
                        return
                }
                let photoIndexPath = IndexPath(item: photoIndex, section: 0)
                // When the request finishes, only update the cell if it's still visible
                if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                    cell.update(with: image)
                }
        }
    }
//    func updateImageView(for photo: Photo) {
//        store.fetchImage(for: photo) {
//            (imageResult) -> Void in
//
//            switch imageResult {
//            case let .success(image):
//                self.imageView.image = image
//            case let .failure(error):
//                print("Error downloading image: \(error)")
//            }
//        }
//    }
    
}

