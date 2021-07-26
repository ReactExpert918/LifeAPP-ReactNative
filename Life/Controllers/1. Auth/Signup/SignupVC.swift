//
//  SignupVC.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FlagPhoneNumber
import JGProgressHUD

class SignupVC: BaseVC {

    @IBOutlet weak var phoneNumberTextField: FPNTextField!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonArrow: UIImageView!
    
    var phoneNumber = ""
    var isValidPhoneNumber = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.displayMode = .picker
        phoneNumberTextField.delegate = self
        phoneNumberTextField.placeholder = R.msgEnterPhone
        phoneNumberTextField.layer.cornerRadius = 5
        
//        phoneNumberTextField.text = "530-324-2463"
        
        subscribeToShowKeyboardNotifications()
        
        checkPhoneNumberValidation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
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
            _ = keyboardRectangle.height
            nextButtonBottomConstraint.constant = 30
        }
    }
    
    func checkPhoneNumberValidation(){
        
        let phoneNumber = phoneNumberTextField.text ?? ""
        
        if (phoneNumber.count > 9) {
            nextButton.backgroundColor = .primaryColor
            nextButtonArrow.tintColor = .white
        } else {
            nextButton.backgroundColor = UIColor(white: 0, alpha: 0.17)
            nextButtonArrow.tintColor = UIColor(white: 0, alpha: 0.31)
        }
    }
    
    @IBAction func onNextPressed(_ sender: Any) {
        
        phoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
        
        if checkValid() {
            showAlert(phoneNumber, message: R.msgSendCode, positive: R.btnSend, negative: R.btnCancel, positiveAction: { (_) in
                self.sendOTPCode()
            }, negativeAction: nil, completion: nil)
        }
    }
    
    fileprivate func checkValid() -> Bool {
        
        if isValidPhoneNumber == false {
            showAlert(R.msgInvalidPhone)
            return false
        }
        
        return true
    }
    
    func sendOTPCode() {
        
        showProgress("Sending...")
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            self.hideProgress()
            if error == nil {
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.gotoNext()
            } else {
                self.showAlert(error?.localizedDescription ?? "")
                return
            }
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func gotoNext() {
        let vc = self.storyboard?.instantiateViewController(identifier: "OTPVerificationVC") as! OTPVerificationVC
        vc.phoneNumber = phoneNumber
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SignupVC: FPNTextFieldDelegate {
    // FNTextFieldDelegate
    func fpnDisplayCountryList() {
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        _ = textField.getFormattedPhoneNumber(format: .E164)!
        checkPhoneNumberValidation()
        if isValid {
            isValidPhoneNumber = true
        } else {
            isValidPhoneNumber = false
        }
    }
}
