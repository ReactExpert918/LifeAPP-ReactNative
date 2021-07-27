//
//  PrivacyEulaVC.swift
//  Life
//
//  Created by Good Developer on 7/26/21.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import PDFKit

class PrivacyEulaVC: BaseVC {

    var privacy = true // false: eula
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    fileprivate func initUI() {
        if privacy {
            title = "Privacy Policy"
            
            let pdfView = PDFView(frame: self.view.bounds)
            pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(pdfView)
            
            pdfView.autoScales = true
            
            let fileURL = Bundle.main.url(forResource: "Privacy", withExtension: "pdf")
            pdfView.document = PDFDocument(url: fileURL!)
        } else {
            title = "EULA"
            
            let pdfView = PDFView(frame: self.view.bounds)
            pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(pdfView)
            
            pdfView.autoScales = true
            
            let fileURL = Bundle.main.url(forResource: "EULA", withExtension: "pdf")
            pdfView.document = PDFDocument(url: fileURL!)
        }
    }


}
