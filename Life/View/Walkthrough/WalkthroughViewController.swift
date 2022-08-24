//
//  WalkthorughViewController.swift
//  Life
//
//  Created by Farbod Rahiminik on 8/24/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import JamitFoundation

class WalkthroughViewController: StatefulView<WalkthroughViewModel> {

    @IBOutlet private weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.register(cellOfType: WalkthroughItemCell.self)
        collectionView.isPagingEnabled = true
    }

    override func didChangeModel() {
        collectionView.reloadData()
    }
}

extension WalkthroughViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cellOfType: WalkthroughItemCell.self, for: indexPath)
        cell.model = model.items[indexPath.item]
        return cell
    }
}
