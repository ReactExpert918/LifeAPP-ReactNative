//
//  OTPVerificationVC.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import DPOTPView
import FirebaseAuth
import JGProgressHUD

class OTPVerificationVC: BaseVC {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonArrow: UIImageView!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var otpCodeView: DPOTPView!
    
    var phoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        otpCodeView.dpOTPViewDelegate = self
        subscribeToShowKeyboardNotifications()
        
        checkOTPValidation(text: otpCodeView.text ?? "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let _ = otpCodeView.becomeFirstResponder()
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
            let _ = keyboardRectangle.height
            nextButtonBottomConstraint.constant = 30
        }
    }
    
    func checkOTPValidation(text: String){
        if(text.count == 6){
            nextButton.backgroundColor = .primaryColor
            nextButtonArrow.tintColor = .white
        } else {
            nextButton.backgroundColor = UIColor(white: 0, alpha: 0.17)
            nextButtonArrow.tintColor = UIColor(white: 0, alpha: 0.31)
        }
    }
    
    @IBAction func onSubmitPressed(_ sender: Any) {
        
        let verificationCode = otpCodeView.text ?? "123456"
        if verificationCode.count != 6 {
            return
        }
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode)
        
        showProgress()
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            self.hideProgress()
            
            if let error = error {
                print(error.localizedDescription)
                self.showAlert(R.errInvalidCode)
                return
            }
            
            self.createPerson()
            
            self.gotoBasicDetailInsertVC()
        }
    }
    
    func createPerson() {
        let userId = AuthUser.userId()
        Persons.create(userId, phone: self.phoneNumber)
    }
    
    func gotoBasicDetailInsertVC() {
        DispatchQueue.main.async {
            let vc =  self.storyboard?.instantiateViewController(identifier: "BasicDetailInsertVC") as! BasicDetailInsertVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension OTPVerificationVC : DPOTPViewDelegate {
   
    func dpOTPViewAddText(_ text: String, at position: Int) {
        //print("addText:- " + text + " at:- \(position)" )
        self.checkOTPValidation(text: text)
    }
    
    func dpOTPViewRemoveText(_ text: String, at position: Int) {
        //print("removeText:- " + text + " at:- \(position)" )
        self.checkOTPValidation(text: text)
    }
    
    func dpOTPViewChangePositionAt(_ position: Int) {
        print("at:-\(position)")
    }
    
    func dpOTPViewBecomeFirstResponder() {
    }
    
    func dpOTPViewResignFirstResponder() {
    }
}
