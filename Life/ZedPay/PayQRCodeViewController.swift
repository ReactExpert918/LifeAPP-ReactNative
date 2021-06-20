//
//  PayQRCodeViewController.swift
//  Life
//
//  Created by mac on 2021/6/20.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import FittedSheets

class PayQRCodeViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    @IBOutlet weak var preView: QRCodeReaderView!{
      didSet {
        preView.setupComponents(with: QRCodeReaderViewControllerBuilder {
          $0.reader                 = qrReader
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
    
    lazy var qrReader: QRCodeReader = QRCodeReader()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        startReader()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //print("Scan disappear")
        super.viewDidDisappear(animated)
        qrReader.stopScanning()
    }
    func startReader(){
        guard checkScanPermissions(), !qrReader.isRunning else { return }
        
        qrReader.didFindCode = { result in
            
            let qrcodeValue = result.value.components(separatedBy: ":")
            let qrCode = qrcodeValue[0]
            if(qrcodeValue.count > 1){
                let qrtype = qrcodeValue[1]
                if(qrtype != "pay"){
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error".localized, message: "Invalid QR code".localized, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                            self.qrReader.startScanning()
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else{
                    let person = realm.object(ofType: Person.self, forPrimaryKey: qrCode)
                    if let person = person{
                        let vc =  self.storyboard?.instantiateViewController(identifier: "payBottomSheetVC") as! PayBottomSheetViewController
                        vc.person = person
                        vc.qrView = self
                        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(470)])
                        self.present(sheetController, animated: false, completion: nil)
                    }else{
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error".localized, message: "Invalid QR code".localized, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                                self.qrReader.startScanning()
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            
            }else{
                self.qrReader.startScanning()
            }
            
        }
        qrReader.startScanning()
    }
    
    private func checkScanPermissions() -> Bool {
      do {
        return try QRCodeReader.supportsMetadataObjectTypes()
      } catch let error as NSError {
        let alert: UIAlertController

        switch error.code {
        case -11852:
            alert = UIAlertController(title: "Error".localized, message: "This app is not authorized to use Back Camera.".localized, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Setting".localized, style: .default, handler: { (_) in
            DispatchQueue.main.async {
              if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(settingsURL)
              }
            }
          }))

            alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        default:
            alert = UIAlertController(title: "Error".localized, message: "Reader not supported by the current device".localized, preferredStyle: .alert)
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
        let vc =  self.storyboard?.instantiateViewController(identifier: "payMyQrVC") as! PayMyQrGenerateViewController

        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(460)])
        
        self.present(sheetController, animated: false, completion: nil)
    }
    
}
