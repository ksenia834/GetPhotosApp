//
//  UIView+MotionEffect.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/27/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import UIKit

extension UIView {
    func addXYMotion(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat ) {
        let xMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x",
                                                  type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = minX
        xMotion.maximumRelativeValue = maxX

        let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y",
                                                  type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = minY
        yMotion.maximumRelativeValue = maxY

        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [xMotion, yMotion]

        self.addMotionEffect(motionEffectGroup)
    }
}
