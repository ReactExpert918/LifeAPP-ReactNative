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

class SignInViewController: UIViewController, UITextViewDelegate {

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
        bottomText.isSelectable = true
        bottomText.isEditable = false
        scrollViewHeightConstraint.constant = UIScreen.main.bounds.size.height
        // Subscribe Keyboard Popup
        //subscribeToShowKeyboardNotifications()
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
            passwordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        }else {
            password.isSecureTextEntry = true
            passwordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        eye_off = !eye_off
    }
    @IBAction func onLoginTapped(_ sender: Any) {
        if userName.text == ""{
            Util.showAlert(vc: self, "Attention" , "Please enter username first.")
            return
        }else if password.text == ""{
            Util.showAlert(vc: self, "Attention" , "Please enter password first.")
            return
        }
        DispatchQueue.main.async {
            self.hud.textLabel.text = "Login..."
            self.hud.show(in: self.view, animated: true)
        }
        Auth.auth().signIn(withEmail: userName.text!, password: password.text!) { [weak self] authResult, error in
            self!.hud.dismiss(afterDelay: 1.0, animated: true)
            if error != nil {
                self!.errorText.text = "Incorrect phone number or password,\nPlease try again!"
                self!.errorText.textColor = UIColor(hexString: "#DF1747")
                self!.errorText.font = UIFont(name: "Montserrat-Regular", size: 14.0)
                return
            }
            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
    
            UIApplication.shared.windows.first?.rootViewController = vc
        }
    }
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    @IBAction func onForgotPasswordTapped(_ sender: Any) {
    }
}
