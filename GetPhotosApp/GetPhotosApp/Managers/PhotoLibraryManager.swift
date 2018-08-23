//
//  PhotoLibraryManager.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/22/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import Foundation
import Photos

final class PhotoLibraryManager: NSObject {
    var photoLibraryDidChanged: ((PHChange) -> Void)?
    var photoLibraryDidSaveImage: ((Error?) -> Void)?

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    // MARK: - Creating collections -

    func createCollection(with name: String, completion: @escaping (PHAssetCollection?, Error? ) -> Void ) {
        var albumPlaceholder: PHObjectPlaceholder?

        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in

            if error != nil || !success {
                completion(nil, error)
            }

            guard let placeholder = albumPlaceholder else {
                completion(nil, nil)
                return
            }

           let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
           completion(album.firstObject, nil)
        })
    }

    // MARK: - Fetching Collections -

    func fetchAssetCollections() -> PHFetchResult<PHAssetCollection> {
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum,
                                                                       subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        return assetCollections
    }

    func fetchAssetCollections(excluding subtypes: [PHAssetCollectionSubtype]) -> [PHAssetCollection] {
        let assetCollections = fetchAssetCollections()
        var reducedCollections: [PHAssetCollection] = []

        assetCollections.enumerateObjects({ collection, _, _ in
            if !subtypes.contains(collection.assetCollectionSubtype) {
                reducedCollections.append(collection)
            }
        })

        return reducedCollections
    }

    func getCameraRollCollection() -> PHAssetCollection? {
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                             subtype: .albumMyPhotoStream, options: nil)
        return albums.firstObject
    }

    func findCollection(name: String) -> PHAssetCollection? {
        let fetchOptions        = PHFetchOptions()
        fetchOptions.predicate  = NSPredicate(format: "title = %@", name)
        let fetchResult         = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                          subtype: .any, options: fetchOptions)
        guard let photoAlbum    = fetchResult.firstObject else { return nil }
        return photoAlbum
    }

    // MARK: - Fetching Assets -

    func fetchAssetIn(collection: PHAssetCollection, mediaType: PHAssetMediaType = PHAssetMediaType.image) -> PHFetchResult<PHAsset> {
        let fetchOptions        = PHFetchOptions()
        fetchOptions.predicate  = NSPredicate(format: "mediaType = %i", mediaType.rawValue)
        let assetsInCollection  = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        return assetsInCollection
    }

    func fetchCoverImage(collection: PHAssetCollection, mediaType: PHAssetMediaType = PHAssetMediaType.image) -> PHFetchResult<PHAsset> {
        let fetchOptions           = PHFetchOptions()
        fetchOptions.fetchLimit    = 1
        fetchOptions.predicate     = NSPredicate(format: "mediaType = %i", mediaType.rawValue)
        let assetsInCollection     = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        return assetsInCollection
    }

    // MARK: - Load Images -

    func loadThumbnailFromAsset(asset: PHAsset, targetSize: CGSize, completion: @escaping ( UIImage? ) -> Void ) {
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize,
                                              contentMode: .aspectFit, options: PHImageRequestOptions(),
                                              resultHandler: { result, _ in
            completion(result)
        })
    }

    func loadImageFromAsset(asset: PHAsset, completion: @escaping ( Data?, String?, UIImageOrientation ) -> Void ) {
        PHImageManager.default().requestImageData(for: asset, options: nil) { data, title, orientation, _ in
            completion(data, title, orientation)
        }
    }

    // MARK: - Saving Images -

    func savePhoto(_ image: UIImage, completion: ((PHAsset?) -> Void )? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let collection = self?.getCameraRollCollection() else {
                DispatchQueue.main.async { completion?(nil) }
                return
            }

            self?.savePhoto(image: image, album: collection, completion: { asset in
                DispatchQueue.main.async { completion?(asset) }
            })
        }
    }

    private func savePhoto(image: UIImage, album: PHAssetCollection, completion: ((PHAsset?) -> Void)? = nil) {
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)

            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else { return }

            placeholder = photoPlaceholder
            let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)

        }, completionHandler: { success, _ in
            guard let placeholder = placeholder else {
                completion?(nil)
                return
            }
            if success {
                let assets: PHFetchResult<PHAsset> =  PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                let asset: PHAsset? = assets.firstObject
                completion?(asset)
            } else {
                completion?(nil)
            }
        })
    }

    func savePhoto(image: UIImage, collectionName: String, completion: ((PHAsset?) -> Void)? = nil) {
        if let album = findCollection(name: collectionName) {
            savePhoto(image: image, album: album, completion: completion)
        } else {
            createCollection(with: collectionName, completion: { collection, _ in
                if let collection = collection {
                    self.savePhoto(image: image, album: collection, completion: completion)
                } else {
                    completion?(nil)
                }
            })
        }
    }
}

extension PhotoLibraryManager: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        photoLibraryDidChanged?(changeInstance)
    }
}
