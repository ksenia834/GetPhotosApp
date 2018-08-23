//
//  ImagePreviewScrollView.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/23/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import UIKit

final class ImagePreviewScrollView: UIScrollView {

    // MARK: - private properties -

    private let defaultMaxZoomScale: CGFloat = 4
    private let defaultMinZoomScale: CGFloat = 1
    private let defaultZoomInScale:  CGFloat = 2

    private lazy var imageView: UIImageView = {
        let imageView                       = UIImageView()
        imageView.contentMode               = .scaleAspectFit
        imageView.backgroundColor           = UIColor.clear
        imageView.clipsToBounds             = true
        return imageView
    }()

    // MARK: - public properties -

    override var bounds: CGRect {
        willSet {
            if imageView.frame == CGRect.zero {
                imageView.frame = frame
            }
        }
    }

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    // MARK: - View lifecycle -

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }

    private func initialSetup() {
        showsVerticalScrollIndicator        = false
        showsHorizontalScrollIndicator      = false
        delegate                            = self
        contentSize = CGSize.zero

        addSubview(imageView)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addGestureGecornizer()
        setZoomScale()
    }

    // MARK: - Helper methods -

    private func setZoomScale() {
        let widthScale      = frame.size.width / imageView.bounds.width
        let heightScale     = frame.size.height / imageView.bounds.height
        let minScale        = min(widthScale, heightScale)

        minimumZoomScale    = defaultMinZoomScale
        zoomScale           = minScale
        maximumZoomScale    = minScale * 5
    }

    // MARK: - Setup Gesture Recognizer -

    private func addGestureGecornizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.isUserInteractionEnabled   = true
        tapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ gesture: UIGestureRecognizer) {
        if zoomScale > defaultMinZoomScale {
            zoomOut(animated: true)
        } else {
            let location = gesture.location(in: self)
            zoomIn(center: location, animated: true)
        }
    }

    private func zoomIn(center: CGPoint, animated: Bool) {
        let zoomRect = zoomRectForScrollView(self, scale: defaultZoomInScale, center: center)
        zoom(to: zoomRect, animated: animated)
    }

    private func zoomOut(animated: Bool) {
        let animationDuration = animated ? 0.3 : 1
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.zoomScale = strongSelf.defaultMinZoomScale
        }
    }

    private func zoomRectForScrollView(_ scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero

        zoomRect.size.height = scrollView.frame.size.height / scale
        zoomRect.size.width  = scrollView.frame.size.width  / scale

        zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)

        return zoomRect
    }
}

// MARK: - UIScrollViewDelegate methods -

extension ImagePreviewScrollView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
