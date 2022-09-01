//
//  WalkthroughItemViewModel.swift
//  Life
//
//  Created by Farbod Rahiminik on 8/24/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import JamitFoundation
import UIKit

struct WalkthroughItemViewModel: ViewModelProtocol {
    let image: UIImage?
    let fullImage: UIImage?
    let description: String

    init(
        image: UIImage? = Self.default.image,
        fullImage: UIImage? = Self.default.fullImage,
        description: String = Self.default.description
    ) {
        self.image = image
        self.fullImage = fullImage
        self.description = description
    }
}

extension WalkthroughItemViewModel {
    static var `default`: WalkthroughItemViewModel = .init(
        image: nil,
        fullImage: nil,
        description: ""
    )
}
