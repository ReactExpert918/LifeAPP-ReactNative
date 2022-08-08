//
//  AdView.swift
//  Life
//
//  Created by Farbod Rahiminik on 8/8/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import JamitFoundation
import SnapKit
import GoogleMobileAds

final class AdView: StatefulView<AdViewModel> {
    private var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBannerView()
        
        bannerView.delegate = self
    }

    private func addBannerToView() {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bannerView)

        bannerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }

    private func setupBannerView() {
        bannerView.adUnitID = model.unitId
        bannerView.rootViewController = model.rootViewController

        bannerView.load(GADRequest())
    }

    override func didChangeModel() {
        super.didChangeModel()

        setupBannerView()
    }
}

extension AdView: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        model.onDidRecieveAd?()
    }
}
