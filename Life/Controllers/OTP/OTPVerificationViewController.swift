//
//  OTPVerificationViewController.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import DPOTPView

class OTPVerificationViewController: UIViewController {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var otpCodeView: DPOTPView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onSubmitPressed(_ sender: Any) {
        
    }
    
    @IBAction func onResendCodePressed(_ sender: Any) {
        
    }
    
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
