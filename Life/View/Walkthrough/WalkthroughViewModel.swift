//
//  WalkthroughViewModel.swift
//  Life
//
//  Created by Farbod Rahiminik on 8/24/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import JamitFoundation

struct WalkthroughViewModel: ViewModelProtocol {
    let items: [WalkthroughItemViewModel]

    init(
        items: [WalkthroughItemViewModel] = Self.default.items
    ) {
        self.items = items
    }
}

extension WalkthroughViewModel {
    static var `default`: WalkthroughViewModel = .init(items: [])
}
