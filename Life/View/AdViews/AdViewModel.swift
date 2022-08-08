//
//  AdViewModel.swift
//  Life
//
//  Created by Farbod Rahiminik on 8/8/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import JamitFoundation
import UIKit

struct AdViewModel: ViewModelProtocol {
    let unitId: String
    let adSize: CGSize
    let rootViewController: UIViewController
    let onDidRecieveAd: VoidCallback?

    init(
        unitId: String = Self.default.unitId,
        adSize: CGSize = Self.default.adSize,
        rootViewController: UIViewController = Self.default.rootViewController,
        onDidRecieveAd: VoidCallback? = Self.default.onDidRecieveAd
    ) {
        self.unitId = unitId
        self.adSize = adSize
        self.rootViewController = rootViewController
        self.onDidRecieveAd = onDidRecieveAd
    }
}

extension AdViewModel {
    static var `default`: AdViewModel = .init(
        unitId: "",
        adSize: CGSize(width: 320, height: 50),
        rootViewController: UIViewController(),
        onDidRecieveAd: nil
    )
}
