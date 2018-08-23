//
//  CaptureSessionManager.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/23/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

enum CaptureSessionError: Error {
    case cantAccessCameraDevice
    case cantAccessCameraDeviceInput
    case failedAddDeviceInput
}

final class CaptureSessionManager: NSObject {
    private var cameraOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var device: AVCaptureDevice?

    private lazy var captureSesssion: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        return session
    }()

    private var photoCaptureCompletion: ( (UIImage?) -> Void )?

    deinit {
        stopCaptureSession()
    }

    // MARK: - Public methods -

    func setupCaptureSession( completion: ((AVCaptureVideoPreviewLayer?, Error?) -> Void) ) {
        guard let device   = AVCaptureDevice.default(for: AVMediaType.video) else {
            completion(nil, CaptureSessionError.cantAccessCameraDevice)
            return
        }

        guard let input    = try? AVCaptureDeviceInput(device: device) else {
            completion(nil, CaptureSessionError.cantAccessCameraDeviceInput)
            return
        }

        self.device         = device
        self.cameraOutput   = AVCapturePhotoOutput()

        if captureSesssion.canAddInput(input) {
            captureSesssion.addInput(input)

            if captureSesssion.canAddOutput(cameraOutput!) {
                captureSesssion.addOutput(cameraOutput!)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                completion(previewLayer, nil)
                startCaptureSession()
            }
        } else {
            completion(nil, CaptureSessionError.failedAddDeviceInput)
        }
    }

    func stopCaptureSession() {
        captureSesssion.stopRunning()
    }

    func startCaptureSession() {
        if device != nil {
            captureSesssion.startRunning()
        }
    }

    func capturePhotoAction(completion: @escaping ((UIImage?) -> Void)) {
        photoCaptureCompletion = completion

        if let settings = capturePhotoSettings() {
            cameraOutput?.capturePhoto(with: settings, delegate: self)
        } else {
            onImageCapturing(image: nil)
        }
    }

    func switchCamera() throws {
        guard let currentDevice = device else {
            throw CaptureSessionError.cantAccessCameraDevice
        }

        let position: AVCaptureDevice.Position = currentDevice.position == .front ? .back : .front
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                          for: AVMediaType.video, position: position) else {
            throw CaptureSessionError.cantAccessCameraDevice
        }

        device = captureDevice
        do {
            clearSessionInputs()
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSesssion.addInput(input)
        } catch {
            throw CaptureSessionError.failedAddDeviceInput
        }
    }

    // MARK: - Private methods -

    private func clearSessionInputs() {
        let inputs = captureSesssion.inputs
        inputs.forEach({ input in captureSesssion.removeInput(input) })
    }

    private func capturePhotoSettings() -> AVCapturePhotoSettings? {
        let settings = AVCapturePhotoSettings()
        guard let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first else { return nil }

        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        return settings
    }

    private func onImageCapturing(image: UIImage? ) {
        DispatchQueue.main.async { [weak self] in
            self?.photoCaptureCompletion?(image)
            self?.photoCaptureCompletion = nil
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate -

extension CaptureSessionManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            onImageCapturing(image: nil)
        } else {
            let imageData = photo.fileDataRepresentation()
            if let data = imageData, let img = UIImage(data: data) {
                onImageCapturing(image: img)
            }
        }
    }
}
