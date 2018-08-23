//
//  SelectView.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/22/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import UIKit

class SelectView: UIView {
    private let defaultMargin: CGFloat = 2.0
    private let elementsOffset: CGFloat = 4.0

    private lazy var imageView: UIImageView = {
        let imageView               = UIImageView(image: #imageLiteral(resourceName: "arrowdown"))
        imageView.contentMode       = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel              = UILabel()
        titleLabel.text             = ""
        titleLabel.textColor        = UIColor.white
        titleLabel.font             = UIFont(name: "AvenirNext-Regular", size: 15)
        return titleLabel
    }()
    
    var didTapAction: (() -> Void)?
    var collapsed: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let strongSelf = self else { return }
                let angle: CGFloat = strongSelf.collapsed ? (180.0 * .pi) / 180 : -(.pi * 2)
                strongSelf.imageView.transform = CGAffineTransform(rotationAngle: angle)
            })
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
        setupSubviews()
        addGestureGecornizer()
    }

    // MARK: - View setup subviews -

    private func setupSubviews() {
        self.addSubview(imageView)
        self.addSubview(titleLabel)

        self.invalidateIntrinsicContentSize()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false

        let margins = self.layoutMarginsGuide
        imageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: -defaultMargin).isActive = true
        imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 10).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0).isActive = true

        titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 30).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: elementsOffset).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: 0).isActive = true
        titleLabel.widthAnchor.constraint(greaterThanOrEqualTo: margins.widthAnchor, multiplier: 0).isActive = true

        titleLabel.sizeToFit()
        self.layoutSubviews()
    }

    // MARK: - Public methods -
    
    func set(title: String?) {
        titleLabel.text = title
    }

    // MARK: - Setup Gesture Recognizer -

    private func addGestureGecornizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ gesture: UIGestureRecognizer) {
        didTapAction?()
    }
}
