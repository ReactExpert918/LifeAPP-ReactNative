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

        bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(model.adSize))
        bannerView.backgroundColor = .orange
        bannerView.delegate = self
        addBannerToView()
    }

    private func addBannerToView() {
        bannerView.removeFromSuperview()
        bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(model.adSize))
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bannerView)

        bannerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(model.adSize.height)
            make.width.equalTo(model.adSize.width)
            make.centerX.equalToSuperview()
        }

        bringSubviewToFront(bannerView)
    }

    private func setupBannerView() {
        bannerView.adUnitID = model.unitId
        bannerView.rootViewController = model.rootViewController

        bannerView.load(GADRequest())
    }

    override func didChangeModel() {
        super.didChangeModel()

        addBannerToView()
        setupBannerView()
    }
}

extension AdView: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        model.onDidRecieveAd?()
        UIView.animate(withDuration: 0.3) {
            bannerView.alpha = 1
        }
    }
}
