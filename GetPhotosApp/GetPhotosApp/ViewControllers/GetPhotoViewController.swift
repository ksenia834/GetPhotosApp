//
//  ViewController.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/21/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import AVFoundation
import CoreImage
import UIKit

final class GetPhotoViewController: UIViewController, ErrorDisplaySupportable {
    
    enum CamerViewControllerState {
        case capturing
        case none
    }
    
    @IBOutlet private weak var previewView:         UIView!
    @IBOutlet private weak var imagePreview:        UIImageView!
    @IBOutlet private weak var cameraControlsView:  UIView!
    @IBOutlet private weak var captureButton:       UIButton!
    @IBOutlet private weak var requestCameraAccessButton: UIButton!
    
    private var sessionManager = CaptureSessionManager()
    
    private var state = CamerViewControllerState.none {
        didSet {
            setupNavigationBarButtons()
        }
    }
    
    private lazy var flipAnimation: CABasicAnimation = {
        let animation           = CABasicAnimation(keyPath: "transform.rotation.y")
        animation.fromValue     = 0
        animation.toValue       = Double(1) * .pi
        animation.duration      = CFTimeInterval(1)
        animation.repeatCount   = 0
        animation.isRemovedOnCompletion = true
        return animation
    }()
    
    // MARK: - View controller lifecycle methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupVisualEffects()
        setupTitles()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionManager.stopCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionManager.startCaptureSession()
    }
    
    // MARK: - Setup Titles and Appearance -
    
    private func setupTitles() {
        requestCameraAccessButton.setTitle(NSLocalizedString("Camera.Notauthorized.Alert", comment: ""), for: .normal)
        requestCameraAccessButton.titleLabel?.numberOfLines = 0
    }
    
    private func setupNavigationBarButtons() {
        switch state {
        case .capturing:
            let rotate = CustomBarButton(image: UIImage(named: "rotate")!, target: self, action: #selector(switchCamera))
            navigationItem.rightBarButtonItem = rotate
            requestCameraAccessButton.isHidden = true
            
        default:
            requestCameraAccessButton.isHidden = false
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    private func setupVisualEffects() {
        captureButton.addXYMotion(minX: -10, maxX: 10, minY: -5, maxY: 5)
        
        captureButton.layer.shadowColor     = UIColor.black.cgColor
        captureButton.layer.shadowOpacity   = 0.5
        captureButton.layer.shadowOffset    = CGSize.zero
        captureButton.layer.shadowRadius    = 10
    }
    
    private func showBlureView() {
        let blur            = UIBlurEffect(style: .dark)
        let blurView        = UIVisualEffectView(effect: blur)
        blurView.frame      = self.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        previewView.addSubview(blurView)
    }
    
    // MARK: - Setup Capture Session -
    
    private func setupCaptureSession() {
        CameraAuthorization().requestCameraAuthorization(completion: { [weak self] authorized in
            guard let strongSelf = self, authorized else { return }
            
            strongSelf.sessionManager.setupCaptureSession { previewLayer, _ in
                guard let previewLayer = previewLayer else { return }
                DispatchQueue.main.async {
                    previewLayer.frame = strongSelf.previewView.bounds
                    strongSelf.previewView.layer.addSublayer(previewLayer)
                    strongSelf.state = .capturing
                }
            }
        })
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
    
    @IBAction private func requestCameraAccess(_ sender: Any) {
        showEventsAcessDeniedAlert(message: NSLocalizedString("Camera.Notauthorized.Alert", comment: ""))
    }
    
    @IBAction private func capturePhotoAction(_ sender: Any) {
        if CameraAuthorization().isAccessDenied {
            showEventsAcessDeniedAlert(message: NSLocalizedString("Camera.Notauthorized.Alert", comment: ""))
            return
        }
        
        sessionManager.capturePhotoAction { [weak self] image in
            self?.imagePreview.image = image
            
            let storyboard = AppStoryboards.photoLibrary
            if let previewViewController = storyboard.instantiateViewController(withIdentifier: "ImagePreviewViewController") as? ImagePreviewViewController {
                previewViewController.image = image
                self?.navigationController?.pushViewController(previewViewController, animated: false)
            }
            
            self?.imagePreview.image = nil
        }
    }
    
    @objc func switchCamera() {
        let blurView        = UIVisualEffectView(frame: previewView.bounds)
        blurView.effect     = UIBlurEffect(style: .dark)
        previewView.addSubview(blurView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            do {
                try self?.sessionManager.switchCamera()
            } catch {
                self?.showError(title: nil, message: error.localizedDescription)
            }
        }
        
        UIView.transition(with: previewView, duration: 0.7, options: .transitionFlipFromLeft, animations: nil) { _ -> Void in
            blurView.removeFromSuperview()
        }
    }
    
    // MARK: - Get photo from Photos -
    
    @IBAction private func showPhotoLibrary(_ sender: Any) {
        let galleryViewController: PhotoGalleryViewController = AppStoryboards.photoLibrary.instantiateViewController()
        self.present(galleryViewController, animated: true, completion: nil)
        
        galleryViewController.onImageSelected = { data, title, orientation in
            galleryViewController.dismiss(animated: true, completion: {
                
                let storyboard = AppStoryboards.photoLibrary
                if let previewViewController = storyboard.instantiateViewController(withIdentifier: "ImagePreviewViewController") as? ImagePreviewViewController {
                    previewViewController.image = UIImage(data: data!)
                    self.navigationController?.pushViewController(previewViewController, animated: true)
                }
            })
        }
    }
}
