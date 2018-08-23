//
//  CustomBarButton.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/23/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import UIKit

class CustomBarButton: UIBarButtonItem {

    convenience init(image: UIImage, target: Any?, action: Selector? ) {
        let button = UIButton(type: .custom)
        button.setImage(image, for: UIControlState.normal)
        button.imageView?.contentMode = .scaleAspectFit

        if let target = target {
            button.addTarget(target, action: action!, for: UIControlEvents.touchUpInside)
        }

        if #available(iOS 11.0, *) {
            button.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
            button.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        } else {
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        }

        self.init(customView: button)
    }
}
