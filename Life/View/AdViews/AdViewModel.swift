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
    let rootViewController: UIViewController

    init(
        unitId: String = Self.default.unitId,
        rootViewController: UIViewController = Self.default.rootViewController
    ) {
        self.unitId = unitId
        self.rootViewController = rootViewController
    }
}

extension AdViewModel {
    static var `default`: AdViewModel = .init(
        unitId: "",
        rootViewController: UIViewController()
    )
}
