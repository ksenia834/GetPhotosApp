//
//  UIStoryboard+Extension.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/24/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import UIKit

extension UIStoryboard {
    func instantiateViewController<T: UIViewController>() -> T where T: StoryboardIdentifiable {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("There is no ViewController with identifier \(T.storyboardIdentifier) in \(self) ")
        }

        return viewController
    }
}
