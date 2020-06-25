//
//  QrCodeViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/26.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import MercariQRScanner
class QrCodeViewController: UIViewController {

    @IBOutlet weak var scannerView: QRScannerView!
    override func viewDidLoad() {
        super.viewDidLoad()

        scannerView.focusImagePadding = 8.0
        scannerView.animationDuration = 0.5

        scannerView.configure(delegate: self)
        scannerView.startRunning()
    }

}

extension QrCodeViewController: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(error)
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        print(code)
    }
}
