//
//  CollectionsViewController.swift
//  GetPhotosApp
//
//  Created by Kseniia on 6/22/18.
//  Copyright © 2018 Sezorus. All rights reserved.
//

import UIKit
import Photos

protocol CollectionsViewControllerDataSource: class {
    func numberOfItems() -> Int
    func setup(cell: CollectionCell, cellForRowAt indexPath: IndexPath)
}

protocol CollectionsViewControllerDelegate: class {
    func didSelectCollection(at indexPath: IndexPath)
}

class CollectionsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    var didSelectColection: ((Int) -> Void)?

    weak var dataSource:  CollectionsViewControllerDataSource?
    weak var delegate:    CollectionsViewControllerDelegate?

    var collections: [(title: String, cover: PHAsset?)]?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
}

extension CollectionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCollection(at: indexPath)
    }
}

extension CollectionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfItems() ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CollectionCell.defaultReuseIdentifier) as! CollectionCell
        dataSource?.setup(cell: cell, cellForRowAt: indexPath)
        return cell
    }
}
