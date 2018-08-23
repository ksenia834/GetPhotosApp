//
//  CameraAuthorization.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/22/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import Foundation
import Photos

struct CameraAuthorization {
    var isCameraAuthorized: Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
    }

    var isAccessDenied: Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .denied
    }

    func requestCameraAuthorization(completion: @escaping (Bool) -> Void) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .authorized:
            completion(true)
        case .denied:
            completion(false)
        default:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                completion(granted)
            }
        }
    }
}
