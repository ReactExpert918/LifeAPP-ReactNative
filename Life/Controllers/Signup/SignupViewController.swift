//
//  SignupViewController.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FirebaseAuth
import FlagPhoneNumber
import JGProgressHUD
class SignupViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: FPNTextField!
    
    var phoneNumber = ""
    var isValidPhoneNumber = false
    let hud = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.displayMode = .picker
        phoneNumberTextField.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        phoneNumberTextField.becomeFirstResponder()
    }
    
    @IBAction func onNextPressed(_ sender: Any) {
         
        phoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
        print(phoneNumber)

        if isValidPhoneNumber == false {
            Util.showAlert(vc: self, "Please enter a valid phone number.", "")
            return
        }
        
        // Confirmation Alert
        let confirmationAlert = UIAlertController(title: phoneNumber, message: "A Verification code will be sent to this number via text messages.", preferredStyle: .alert)

        confirmationAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action: UIAlertAction!) in
            self.sendOTPCode()
        }))

        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    func sendOTPCode() {
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
            let vc =  self.storyboard?.instantiateViewController(identifier: "otpVerificationViewController") as! OTPVerificationViewController
            vc.setPhoneNumber(withPhoneNumber: self.phoneNumber)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SignupViewController: FPNTextFieldDelegate {
    // FNTextFieldDelegate
    func fpnDisplayCountryList() {

    }
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            let phoneNumber = textField.getFormattedPhoneNumber(format: .E164)!
            isValidPhoneNumber = true
        } else {
            isValidPhoneNumber = false
        }

    }
}
