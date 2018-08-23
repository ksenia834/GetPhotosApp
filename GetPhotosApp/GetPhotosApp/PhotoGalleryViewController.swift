//
//  PhotoGalleryViewController.swift
//  PhotoFilter
//
//  Created by Kseniia on 6/22/18.
//  Copyright © 2018 Kseniia. All rights reserved.
//

import UIKit
import Photos

final class PhotoGalleryViewController: UIViewController, StoryboardIdentifiable {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionSelectInfoView: SelectView!

    private var collections:        [PHAssetCollection]?
    private var assets:             PHFetchResult<PHAsset>?
    private var collectionsInfo:    [(title: String, asset: PHAsset?)]?
    private var currentCollection:  PHAssetCollection?
    private var collectionsViewController: CollectionsViewController?

    private let manager  = PhotoLibraryManager()
    var onImageSelected: ((Data?, String?, UIImage.Orientation? ) -> Void)?

    // MARK: - UIViewController lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupAppearance()
        loadCollections()

        manager.photoLibraryDidChanged = { change in
            //            let changeDetails = changeInstance.changeDetailsForFetchResult(images)
            //            self.images = changeDetails.fetchResultAfterChanges
            //            dispatch_async(dispatch_get_main_queue()) {
            //                // Loop through the visible cell indices
            //                let indexPaths = self.collectionView?.indexPathsForVisibleItems()
            //                for indexPath in indexPaths as! [NSIndexPath]{
            //                    if changeDetails.changedIndexes.containsIndex(indexPath.item) {
            //                        let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as! PhotosCollectionViewCell
            //                        cell.imageAsset = changeDetails.fetchResultAfterChanges[indexPath.item] as? PHAsset
            //                    }
            //                }
            //            }
        }
    }

    // MARK: - Setup Titles and Appearance -

    private func setupAppearance() {
        collectionSelectInfoView.didTapAction = { [weak self] in
            self?.showPhotoLibraryCollections()
        }
    }

    // MARK: - Setup Data -

    private func selectCollection(collection: PHAssetCollection) {
        if collection == currentCollection { return }

        currentCollection = collection
        updateCurrentTitle(collection.localizedTitle)
        loadAssets(from: collection)
    }

    private func updateCurrentTitle(_ title: String?) {
        collectionSelectInfoView.set(title: title)
    }

    // MARK: Load Data

    private func loadCollections() {
        let auth = PhotoLibraryAuthorization()
        auth.requestPhotoLibraryAuthorization { [weak self] authorezed in
            guard let strongSelf = self else { return }

            if !authorezed {
                strongSelf.showEventsAcessDeniedAlert(message: NSLocalizedString("Photos.Notauthorized.Alert", comment: ""))
                return
            }

            strongSelf.collections = strongSelf.manager.fetchAssetCollections(excluding: [.smartAlbumVideos, .smartAlbumTimelapses,
                                                                                          .smartAlbumLivePhotos, .smartAlbumSlomoVideos,
                                                                                          .smartAlbumPanoramas, .smartAlbumAnimated, .smartAlbumBursts])
            if let firstCollection = strongSelf.collections?.first {
                DispatchQueue.main.async {
                    strongSelf.selectCollection(collection: firstCollection)
                }
            }
        }
    }

    private func showEventsAcessDeniedAlert(message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { _ in
            if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
            }
        }

        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Default.Titles.Cancel", comment: "Default.Titles.Cancel"), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    private func loadAssets(from collection: PHAssetCollection) {
        self.assets = manager.fetchAssetIn(collection: collection)
        self.collectionView.reloadData()

        guard let assets = assets else { return }
        let lastRow = assets.count - 1

        if lastRow > 0 {
            let lastItemIndexPath = IndexPath(item: lastRow, section: 0)
            self.collectionView.scrollToItem(at: lastItemIndexPath, at: .bottom, animated: false)
        }
    }

    private func getCollectionsInfo() -> [(title: String, asset: PHAsset?)]? {
        guard let collection = self.collections else { return nil }

        var result: [(title: String, asset: PHAsset?)] = []
        for index in 0..<collection.count {
            let collection  = collection[index]
            let item = (collection.localizedTitle!, manager.fetchCoverImage(collection: collection).firstObject)
            result.append(item)
        }

        return result
    }

    private func showPhotoLibraryCollections() {
        if collectionsViewController == nil {
            let viewController = AppStoryboards.photoLibrary.instantiateViewController(withIdentifier: "CollectionsViewController") as? CollectionsViewController
            viewController.modalPresentationStyle = .popover
            viewController.preferredContentSize = CGSize(width: 300, height: 300)
            viewController.popoverPresentationController?.delegate = self
            viewController.dataSource = self
            viewController.delegate = self
            if collectionsInfo == nil {
                collectionsInfo = getCollectionsInfo()
            }

            present(viewController, animated: true, completion: nil)
            collectionSelectInfoView.collapsed = !collectionSelectInfoView.collapsed
            collectionsViewController = viewController

        } else {
            hidePhotoLibraryCollections()
        }

    }

    private func hidePhotoLibraryCollections() {
        collectionsViewController?.dismiss(animated: true, completion: nil)
        collectionsViewController = nil
        collectionSelectInfoView.collapsed = false
    }

}

// MARK: - UICollectionViewDelegate methods -

extension PhotoGalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = assets?[indexPath.row] else { return }
        manager.loadImageFromAsset(asset: asset, completion: { [weak self] data, title, orientation in
            self?.onImageSelected?(data, title, orientation)
        })
    }
}

// MARK: - UICollectionViewDataSource methods -

extension PhotoGalleryViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.defaultReuseIdentifier,
                                                      for: indexPath) as! ImageCollectionViewCell

        if let asset = assets?[indexPath.row] {
            let scale = UIScreen.main.scale
            manager.loadThumbnailFromAsset(asset: asset,
                                           targetSize: CGSize(width: cell.imageView.bounds.width * scale, height: cell.imageView.bounds.height * scale),
                                           completion: { image in
                cell.imageView.image = image
            })
        }

        return cell
    }

    @IBAction private func closeGallery(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: - UICollectionViewDelegateFlowLayout methods -

extension PhotoGalleryViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {

        let sideSize = collectionView.frame.width / 3 - 15
        return CGSize(width: sideSize, height: sideSize)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate methods -

extension PhotoGalleryViewController: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .any
        popoverPresentationController.barButtonItem = UIBarButtonItem(customView: collectionSelectInfoView)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        collectionSelectInfoView.collapsed = !collectionSelectInfoView.collapsed
    }
}

// MARK: - CollectionsViewControllerDataSource methods -

extension PhotoGalleryViewController: CollectionsViewControllerDataSource {
    func numberOfItems() -> Int {
        return collectionsInfo?.count ?? 0
    }

    func setup(cell: CollectionCell, cellForRowAt indexPath: IndexPath) {
        guard let collectionInfo = collectionsInfo?[indexPath.row] else { return }
        cell.setFolderName(collectionInfo.title)

        guard let asset = collectionInfo.asset else {
            cell.coverImageView.image = UIImage(named: "picture")
            return
        }
        manager.loadThumbnailFromAsset(asset: asset, targetSize: cell.coverImageView.bounds.size, completion: { image in
            cell.coverImageView.image = image
        })
    }
}

// MARK: - CollectionsViewControllerDelegate methods -

extension PhotoGalleryViewController: CollectionsViewControllerDelegate {
    func didSelectCollection(at indexPath: IndexPath) {
        hidePhotoLibraryCollections()

        if let collection = collections?[indexPath.row] {
            selectCollection(collection: collection)
        }
    }
}
