//
//  CollectionCell.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/22/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import UIKit

class CollectionCell: UITableViewCell, ReusableView {
    @IBOutlet weak var coverImageView:           UIImageView!
    @IBOutlet private weak var folderNameLabel:  UILabel!

    func setFolderName(_ folderName: String) {
        folderNameLabel.text = folderName
    }
}
