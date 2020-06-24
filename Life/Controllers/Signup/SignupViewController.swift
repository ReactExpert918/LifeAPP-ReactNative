//
//  SignupViewController.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class SignupViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onNextPressed(_ sender: Any) {
        
        let vc =  self.storyboard?.instantiateViewController(identifier: "otpVerificationViewController") as! OTPVerificationViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
