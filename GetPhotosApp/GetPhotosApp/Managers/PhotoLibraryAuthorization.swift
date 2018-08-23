//
//  PhotoLibraryAccess.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/22/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import AVFoundation
import Foundation
import Photos

struct PhotoLibraryAuthorization {
    var isPhotoLibraryAuthorized: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }

    func requestPhotoLibraryAuthorization(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization({ status in
            switch status {
            case .authorized:
                completion(true)
            case .denied, .restricted:
                completion(false)
            default:
                completion(false)
            }
        })
    }
}
