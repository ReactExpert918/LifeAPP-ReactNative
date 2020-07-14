//
//  QrCodeViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/26.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import FittedSheets
class QrCodeViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    @IBOutlet weak var preView: QRCodeReaderView!{
      didSet {
        preView.setupComponents(with: QRCodeReaderViewControllerBuilder {
          $0.reader                 = reader
          $0.showTorchButton        = false
          $0.showSwitchCameraButton = false
          $0.showCancelButton       = false
          $0.showOverlayView        = true
          $0.rectOfInterest         = CGRect(x: 0.15, y: 0.2, width: 0.7, height: 0.4)
        })
      }
    }
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()

        dismiss(animated: true) { [weak self] in
          let alert = UIAlertController(
            title: "QRCodeReader",
            message: String (format:"%@ (of type %@)", result.value, result.metadataType),
            preferredStyle: .alert
          )
          alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

          self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()

        dismiss(animated: true, completion: nil)
    }
    
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
      let builder = QRCodeReaderViewControllerBuilder {
        $0.reader                  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        $0.showTorchButton         = true
        $0.preferredStatusBarStyle = .lightContent
        $0.showOverlayView         = true
        $0.rectOfInterest          = CGRect(x: 0.15, y: 0.15, width: 0.85, height: 0.85)
        
        $0.reader.stopScanningWhenCodeIsFound = false
      }
      
      return QRCodeReaderViewController(builder: builder)
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        startReader()
    }
    func startReader(){
        guard checkScanPermissions(), !reader.isRunning else { return }

        reader.didFindCode = { result in
            let vc =  self.storyboard?.instantiateViewController(identifier: "addFriendBottomSheetVC") as! AddFriendBottomSheetViewController
            self.reader.startScanning()
            let qrcodeValue = result.value.components(separatedBy: "timestamp")
            vc.qrCode = qrcodeValue[0]

            let sheetController = SheetViewController(controller: vc, sizes: [.fixed(376)])
            sheetController.blurBottomSafeArea = false
            sheetController.adjustForBottomSafeArea = false

            // Make corners more round
            sheetController.topCornersRadius = 15

            // It is important to set animated to false or it behaves weird currently
            self.present(sheetController, animated: false, completion: nil)
            print("Completion with result: \(result.value) of type \(result.metadataType)")
        }
        reader.startScanning()
    }
    
    private func checkScanPermissions() -> Bool {
      do {
        return try QRCodeReader.supportsMetadataObjectTypes()
      } catch let error as NSError {
        let alert: UIAlertController

        switch error.code {
        case -11852:
          alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)

          alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
            DispatchQueue.main.async {
              if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(settingsURL)
              }
            }
          }))

          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        default:
          alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }

        present(alert, animated: true, completion: nil)

        return false
      }
    }
    @IBAction func onBackTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onMyQrTapped(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "myQrVC") as! MyQrGenerateViewController

        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(460)])
        sheetController.blurBottomSafeArea = false
        sheetController.adjustForBottomSafeArea = false

        // Make corners more round
        sheetController.topCornersRadius = 15

        // It is important to set animated to false or it behaves weird currently
        self.present(sheetController, animated: false, completion: nil)
    }
    
}
