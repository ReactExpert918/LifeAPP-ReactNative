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
    let description: String

    init(
        image: UIImage? = Self.default.image,
        description: String = Self.default.description
    ) {
        self.image = image
        self.description = description
    }
}

extension WalkthroughItemViewModel {
    static var `default`: WalkthroughItemViewModel = .init(
        image: nil,
        description: ""
    )
}
