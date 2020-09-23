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
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButton: RoundButton!
    @IBOutlet weak var nextButtonArrow: UIImageView!
    
    var phoneNumber = ""
    var isValidPhoneNumber = false
    let hud = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.displayMode = .picker
        phoneNumberTextField.delegate = self
        phoneNumberTextField.placeholder = "Enter your mobile number"
        // Background
        //phoneNumberTextField.backgroundColor = UIColor(white: 0, alpha: 0.08)
        phoneNumberTextField.layer.cornerRadius = 5
        // Subscribe Keyboard Popup
        subscribeToShowKeyboardNotifications()
        //
        checkPhoneNumberValidation()
    }
    override func viewDidAppear(_ animated: Bool) {
        phoneNumberTextField.becomeFirstResponder()
    }
    
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            nextButtonBottomConstraint.constant = keyboardHeight + 30
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            nextButtonBottomConstraint.constant = 30
        }
    }
    func checkPhoneNumberValidation(){
        let phoneNumber = phoneNumberTextField.text ?? ""
        if(phoneNumber.count>9){
            nextButton.backgroundColor = UIColor(hexString: "#16406F")
            nextButtonArrow.tintColor = .white
        }
        else{
            nextButton.backgroundColor = UIColor(white: 0, alpha: 0.17)
            nextButtonArrow.tintColor = UIColor(white: 0, alpha: 0.31)
        }
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
        let phoneNumber = textField.getFormattedPhoneNumber(format: .E164)!
        checkPhoneNumberValidation()
        if isValid {
            isValidPhoneNumber = true
        } else {
            isValidPhoneNumber = false
        }

    }
}
