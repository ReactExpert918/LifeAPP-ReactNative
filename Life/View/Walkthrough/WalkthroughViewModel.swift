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
    let fromSetting: Bool

    init(
        items: [WalkthroughItemViewModel] = Self.default.items,
        fromSetting: Bool = false
    ) {
        self.items = items
        self.fromSetting = fromSetting
    }
}

extension WalkthroughViewModel {
    static var `default`: WalkthroughViewModel = .init(items: [
            .init(image: .init(named: "walkthrough1"), description: "walkthrough1".localized),
            .init(image: .init(named: "walkthrough2"), description: "walkthrough2".localized),
            .init(image: .init(named: "walkthrough3"), description: "walkthrough3".localized),
            .init(image: .init(named: "walkthrough4"), description: "walkthrough4".localized),
            .init(image: .init(named: "walkthrough5"), description: "walkthrough5".localized),
            .init(image: .init(named: "walkthrough6"), description: "walkthrough6".localized)
    ])
}
