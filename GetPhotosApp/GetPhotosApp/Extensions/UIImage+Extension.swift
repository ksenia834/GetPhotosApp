//
//  UIImage+Extension.swift
//  GetPhotosApp
//
//  Created by Kseniia on 8/19/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import UIKit

extension UIImage {
    enum Compression: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func compressedData(_ quality: Compression) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
}
