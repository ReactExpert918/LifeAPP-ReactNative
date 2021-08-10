//
//  SignInViewController.swift
//  Life
//
//  Created by XianHuang on 6/23/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class SignInViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var jaBottomText: UITextView!
    @IBOutlet weak var passwordEye: UIButton!
    @IBOutlet weak var bottomText: UITextView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    let hud = JGProgressHUD(style: .light)
    var eye_off = true
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomText.delegate = self
        userName.delegate = self
        password.delegate = self
        bottomText.isSelectable = true
        bottomText.isEditable = false
        scrollViewHeightConstraint.constant = UIScreen.main.bounds.size.height
        print(bottomText.attributedText.string)
        let langStr = Locale.current.languageCode
        print(langStr!)
        if(langStr! == "ja"){
            bottomText.isHidden = true
            jaBottomText.isHidden = false
        }else{
            bottomText.isHidden = false
            jaBottomText.isHidden = true
        }
//        userName.text = "topdev@gmail.com"
//        password.text = "123456"
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onRegisterTapped(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "signupViewController") as! SignupViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onPasswordEyeTapped(_ sender: Any) {
        if eye_off{
            password.isSecureTextEntry = false
            passwordEye.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }else {
            password.isSecureTextEntry = true
            passwordEye.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }
        eye_off = !eye_off
    }
    @IBAction func onLoginTapped(_ sender: Any) {
        if userName.text == ""{
            Util.showAlert(vc: self, "Attention".localized , "Please enter email first.".localized)
            return
        }else if password.text == ""{
            Util.showAlert(vc: self, "Attention".localized , "Please enter password first.".localized)
            return
        }
        DispatchQueue.main.async {
            self.hud.textLabel.text = "Logging in...".localized
            self.hud.show(in: self.view, animated: true)
        }
        Auth.auth().signIn(withEmail: userName.text!, password: password.text!) { [weak self] authResult, error in
            if error != nil {
                self?.hud.dismiss()
                self!.errorText.text = "Incorrect email or password,\nPlease try again!".localized
                self!.errorText.textColor = UIColor(hexString: "#DF1747")
                self!.errorText.font = UIFont(name: "Montserrat-Regular", size: 14.0)
                return
            }
            PrefsManager.setEmail(val: self?.userName?.text ?? "")
            PrefsManager.setPassword(val: self?.password?.text ?? "")
            self?.loadPerson()
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Persons.update(lastActive: Date().timestamp())
                Persons.update(oneSignalId: PrefsManager.getFCMToken())
                        
            //}
        }
    }
    func loadPerson() {

        let userId = AuthUser.userId()
        FireFetcher.fetchPerson(userId) { error in
            self.hud.dismiss()
            if (error == nil) {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: Notification.Name(NotificationStatus.NOTIFICATION_USER_LOGGED_IN), object: nil)
                    
                    UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            
                    UIApplication.shared.windows.first?.rootViewController = vc
                }
            }
            else {
                self.errorText.text = "Network connection error,\nPlease try again!".localized
                self.errorText.textColor = UIColor(hexString: "#DF1747")
                self.errorText.font = UIFont(name: "Montserrat-Regular", size: 14.0)

            }
        }
    }

    func createPerson() {

        let email = (userName.text ?? "").lowercased()

        let userId = AuthUser.userId()
        Persons.create(userId, email: email)
    }
    
    @IBAction func onForgotPasswordTapped(_ sender: Any) {
        
        let vc =  self.storyboard?.instantiateViewController(identifier: "forgotPassword") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.superview?.viewWithTag(nextTag) as UIResponder?

        if nextResponder != nil {
            // Found next responder, so set it
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }

        return false
    }
}
