//
//  MainAppTheme.swift
//  GetPhotosApp
//
//  Created by Kseniia on 8/20/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import UIKit

class MainAppTheme {
    
    enum ColorPalette {
        static let primaryColorDark   = UIColor(red: 35/255, green: 41/255, blue: 49/255, alpha: 1)
        static let primaryColorLight  = UIColor(red: 57/255, green: 62/255, blue: 70/255, alpha: 1)
        static let secondaryColor     = UIColor(red: 0.0, green: 0.3285, blue: 0.5749, alpha: 1.0)
        static let primaryTextColor   = UIColor.white
    }

    enum Fonts: String {
        case regular        = "Avenir"
        case thin           = "AvenirNext-Regular"
        case heavyItalic    = "AvenirNext-HeavyItalic"

        func of(size: CGFloat) -> UIFont? {
            return UIFont(name: self.rawValue, size: size)
        }
    }

    // MARK: - Colors -

    var mainBackgroundColor: UIColor {
        return ColorPalette.primaryColorDark
    }

    var navigationBarColor: UIColor {
        return ColorPalette.primaryColorLight
    }

    var navigationBarTintColor: UIColor {
        return ColorPalette.primaryTextColor
    }

    var navigationBarBarTintColor: UIColor {
        return ColorPalette.primaryColorLight
    }
    
    // MARK: - Fonts -

    var navigationBarTitleFont: UIFont {
        return Fonts.regular.of(size: 20) ?? UIFont.systemFont(ofSize: 20)
    }

    // MARK: - Setup Appearance -

    func setupNavigationBarAppearance() {
        let navigationBarAppearace              = UINavigationBar.appearance()
        navigationBarAppearace.tintColor        = navigationBarTintColor
        navigationBarAppearace.barTintColor     = navigationBarBarTintColor
        navigationBarAppearace.isTranslucent    = false
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor: ColorPalette.primaryTextColor, NSAttributedStringKey.font: navigationBarTitleFont]
    }
}
