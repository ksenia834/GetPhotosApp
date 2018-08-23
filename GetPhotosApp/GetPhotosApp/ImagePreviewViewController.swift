//
//  ImagePreviewViewController.swift
//  PhotoFilter
//
//  Created by Kseniia on 6/23/18.
//  Copyright © 2018 Kseniia. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController, ActivityIndicatorViewable {

    // MARK: private properties

    @IBOutlet private weak var previewScrollView: ImagePreviewScrollView!

    // MARK: public properties

    var preview: UIImage?

    // MARK: UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupImagePreview()
        setupNavigationItems()
    }

    // MARK: Setup Data and Appearance

    private func setupImagePreview() {
        previewScrollView.image = preview
    }

    private func setupNavigationItems(saveButtonEnabled: Bool = true) {
        let clear = CustomBarButton(image: UIImage(named: "close")!, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = clear

//        let save = CustomBarButton(image: UIImage(named: "save")!, target: self, action: #selector(saveImage))
        let process = CustomBarButton(image: UIImage(named: "done")!, target: self, action: #selector(processImage))

//        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        let spacer2 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//
        let buttons = [process]//saveButtonEnabled ? [process, spacer, spacer2, save] : [process]
        navigationItem.rightBarButtonItems = buttons
    }

    // MARK: BarButtons actions

    @objc private func cancel() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @objc private func processImage() {
        let storyboard = AppStoryboards.main
        let controller = storyboard.instantiateViewController(withIdentifier: "BaseEditingMenuViewController") as? BaseEditingMenuViewController
        controller.image = preview
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func saveImage() {
        guard let image = preview else { return }
        self.startAnimation()
        PhotoLibraryManager().savePhoto(image, completion: { [weak self] result in
            if result != nil {
                self?.setupNavigationItems(saveButtonEnabled: false)
            }
            self?.stopAnimation()
        })
    }
}
