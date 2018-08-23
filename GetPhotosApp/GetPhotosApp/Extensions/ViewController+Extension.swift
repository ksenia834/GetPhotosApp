//
//  ViewController+Extension.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/23/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import UIKit

protocol ErrorDisplaySupportable {
    func showError(title: String?, message: String)
}

extension ErrorDisplaySupportable where Self: UIViewController {
    func showError(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("Default.Titles.Ok", comment: ""),
                                   style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}
