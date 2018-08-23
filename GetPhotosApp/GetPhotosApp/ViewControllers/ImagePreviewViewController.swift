//
//  ImagePreviewViewController.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/23/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import UIKit

final class ImagePreviewViewController: UIViewController {

    // MARK: private properties -

    @IBOutlet private weak var previewScrollView: ImagePreviewScrollView!

    // MARK: public properties -

    var image: UIImage?

    // MARK: UIViewController lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()

        setupImagePreview()
        setupNavigationItems()
    }

    // MARK: Setup Data and Appearance -

    private func setupImagePreview() {
        previewScrollView.image = image
    }

    private func setupNavigationItems(saveButtonEnabled: Bool = true) {
        let save = CustomBarButton(image: UIImage(named: "share_icon")!, target: self, action: #selector(shareImage))
        navigationItem.rightBarButtonItem = save
    }

    // MARK: BarButtons actions -

    @objc private func cancel() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @objc private func shareImage() {
        guard let image = self.image, let imageData = image.compressedData(.lowest) else { return }
        let imageToShare = [imageData]

        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            print("error \(String(describing: error))")
        }

        self.present(activityViewController, animated: true, completion: nil)
    }
}
