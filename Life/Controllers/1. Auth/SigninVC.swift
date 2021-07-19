//
//  SigninVC.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FirebaseAuth

class SigninVC: BaseVC {

    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var passwordEye: UIButton!
    
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    var eye_off = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        txtEmail.delegate = self
        txtPassword.delegate = self
        scrollViewHeightConstraint.constant = UIScreen.main.bounds.size.height
        
        
        txtEmail.text = "test@test.com"
        txtPassword.text = "1234567890"
    }
    
    @IBAction func onRegisterTapped(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "SignupVC") as! SignupVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onpasswordEyeTapped(_ sender: Any) {
        if eye_off{
            txtPassword.isSecureTextEntry = false
            passwordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        }else {
            txtPassword.isSecureTextEntry = true
            passwordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        eye_off = !eye_off
    }
    
    @IBAction func onLoginTapped(_ sender: Any) {
        if checkValid() {
            doLoginAction()
        }
    }
    
    fileprivate func checkValid() -> Bool {
        
        if txtEmail.text!.trim().isEmpty {
            showAlert(R.msgEnterEmail)
            return false
        }
        
        if !Utils.shared.isValidEmail(txtEmail.text!.trim()) {
            showAlert(R.msgInvalidEmail)
            return false
        }
        
        if txtPassword.text!.trim().isEmpty {
            showAlert(R.msgEnterPassword)
            return false
        }
        
        return true
    }
    
    fileprivate func doLoginAction() {
        showProgress("Logging in...")
        
        Auth.auth().signIn(withEmail: txtEmail.text!, password: txtPassword.text!) { [weak self] authResult, error in
            if error == nil {
                self?.loadPerson()
            } else {
                self?.hideProgress()
                
                self!.lblError.text = R.errFailedSignin
                self!.lblError.textColor = .errorRedColor //UIColor(hexString: "#DF1747")
                self!.lblError.font = UIFont(name: MyFont.MontserratRegular, size: 14.0)
                return
            }
        }
    }
    
    fileprivate func loadPerson() {
        
        PrefsManager.setEmail(val: txtEmail.text!)
        
        let userId = AuthUser.userId()
        print("*****************************")
        print(userId)
        FireFetcher.fetchPerson(userId) { error in
            self.hideProgress()
            if (error == nil) {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: Notification.Name(NotificationStatus.NOTIFICATION_USER_LOGGED_IN), object: nil)
                    
                    UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            
                    UIApplication.shared.windows.first?.rootViewController = vc
                }
            } else {
                self.lblError.text = "Network connection error,\nPlease try again!"
                self.lblError.textColor = UIColor(hexString: "#DF1747")
                self.lblError.font = UIFont(name: "Montserrat-Regular", size: 14.0)

            }
        }
    }

    func createPerson() {

        let email = (txtEmail.text ?? "").lowercased()

        let userId = AuthUser.userId()
        Persons.create(userId, email: email)
    }
    
    @IBAction func onForgottxtPasswordTapped(_ sender: Any) {
    }
    
    
}

extension SigninVC: UITextFieldDelegate {
    // MARK: - UITextField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == txtEmail) {
            txtPassword.becomeFirstResponder()
        } else if(textField == txtPassword) {
            if (checkValid()) {
                doLoginAction()
            }
        }
        
        textField.resignFirstResponder()
        return false
    }
}
