//
//  WalkthroughItemView.swift
//  Life
//
//  Created by Farbod Rahiminik on 8/24/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import JamitFoundation

class WalkthroughItemView: StatefulView<WalkthroughItemViewModel> {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didChangeModel() {
        super.didChangeModel()

        descriptionLabel.text = model.description
        descriptionLabel.sizeToFit()
        imageView.image = model.image
    }

}
