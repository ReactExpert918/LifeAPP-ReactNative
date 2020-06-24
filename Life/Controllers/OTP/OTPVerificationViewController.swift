//
//  OTPVerificationViewController.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import DPOTPView
import FirebaseAuth
import JGProgressHUD
class OTPVerificationViewController: UIViewController {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var otpCodeView: DPOTPView!
    
    let hud = JGProgressHUD(style: .light)
    
    var phoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneNumberLabel.text = phoneNumber
    }
    
    func setPhoneNumber(withPhoneNumber phoneNumber: String){
        self.phoneNumber = phoneNumber
        
    }
    @IBAction func onSubmitPressed(_ sender: Any) {
        let verificationCode = otpCodeView.text ?? "123456"
        if verificationCode.count != 6 {
            return
        }
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: verificationCode)
        DispatchQueue.main.async {
            self.hud.show(in: self.view, animated: true)
        }
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                self.hud.dismiss()
                Util.showAlert(vc: self, error.localizedDescription , "")
                return
            }
            // OTP Verification completed
            self.hud.textLabel.text = "Signup successful."
            self.hud.dismiss(afterDelay: 2.0, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now()+2.1, execute: {
                self.gotoMainViewController()
            })
        }
    }
    
    func gotoMainViewController() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        UIApplication.shared.windows.first?.rootViewController = vc
    }
    @IBAction func onResendCodePressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.hud.textLabel.text = "Sending..."
            self.hud.show(in: self.view, animated: true)
        }
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            self.hud.dismiss(afterDelay: 1.0, animated: true)
            if error != nil {
                Util.showAlert(vc: self, error?.localizedDescription ?? "", "")
                return
            }
            // Save Verification ID
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
    }
    
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
