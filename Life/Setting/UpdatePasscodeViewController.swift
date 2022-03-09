//
//  UpdatePasscodeViewController.swift
//  Life
//
//  Created by mac on 2021/6/27.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import RealmSwift
import JGProgressHUD
class UpdatePasscodeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var informLabel: UILabel!
    
    @IBOutlet weak var oldPasswordEye: UIButton!
    
    @IBOutlet weak var newPasswordEye: UIButton!
    
    @IBOutlet weak var confirmPasswordEye: UIButton!
    
    var delegate: UpdatePayDelegateProtocol? = nil
    
    var oldpassword_eye_off = true
    var newpassword_eye_off = true
    var confirmpassword_eye_off = true
    
    private var tokenStripeCustomer: NotificationToken? = nil
    private var stripeCustomers = realm.objects(StripeCustomer.self).filter(falsepredicate)
    let hud = JGProgressHUD(style: .light)
    override func viewDidLoad() {
        super.viewDidLoad()

        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        informLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        oldPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onOldPasswordEyeTapped(_ sender: Any) {
        if oldpassword_eye_off {
            oldPasswordTextField.isSecureTextEntry = false
            oldPasswordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        } else {
            oldPasswordTextField.isSecureTextEntry = true
            oldPasswordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        oldpassword_eye_off = !oldpassword_eye_off
    }
    
    
    @IBAction func onNewPasswordEyeTapped(_ sender: Any) {
        if newpassword_eye_off {
            newPasswordTextField.isSecureTextEntry = false
            newPasswordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        } else {
            newPasswordTextField.isSecureTextEntry = true
            newPasswordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        newpassword_eye_off = !newpassword_eye_off
    }
    
    @IBAction func onConfirmPasswordEyeTapped(_ sender: Any) {
        if confirmpassword_eye_off {
            confirmPasswordTextField.isSecureTextEntry = false
            confirmPasswordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        } else {
            confirmPasswordTextField.isSecureTextEntry = true
            confirmPasswordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        confirmpassword_eye_off = !confirmpassword_eye_off
    }
    
    func showInformText(message: String)
    {
        informLabel.text = message
        informLabel.isHidden = false
        
    }
    @IBAction func onSubmitTapped(_ sender: Any) {
        let oldPassword = self.oldPasswordTextField.text
        
        if oldPassword?.isEmpty == true {
            self.showInformText(message: "Please enter passcode.")
            return
        }
        
        let newPassword = self.newPasswordTextField.text
        
        if newPassword?.isEmpty == true {
            self.showInformText(message: "New Passcode Can't empty.")
            return
        }
        if newPasswordTextField.text == confirmPasswordTextField.text {
            self.informLabel.isHidden = true
            
            let predicate = NSPredicate(format: "userId == %@", AuthUser.userId())
            stripeCustomers = realm.objects(StripeCustomer.self).filter(predicate)
            guard let stripeCustomer = stripeCustomers.first else{
                return
            }
            
            if !stripeCustomer.checkPasscode(passcode: oldPassword ?? "") {
                self.showInformText(message: "Please input correct passcode.")
                return
            }
            //print(stripeCustomer.passcode.decryptedString())
            stripeCustomer.update(passcode: newPasswordTextField.text!)
            tokenStripeCustomer?.invalidate()
            stripeCustomers.safeObserve({ changes in
                self.updatePasscode()
            }, completion: { token in
                self.tokenStripeCustomer = token
            })
            self.hud.show(in: self.view, animated: true)
            
            
        }
        else{
            showInformText(message: "Passcode not match")
        }
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 4
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    func updatePasscode(){
        let predicate = NSPredicate(format: "userId == %@", AuthUser.userId())
        stripeCustomers = realm.objects(StripeCustomer.self).filter(predicate)
        guard let stripeCustomer = stripeCustomers.first else{
            return
        }
        if(stripeCustomer.passcode.decryptedString() == newPasswordTextField.text){
            self.hud.dismiss()
            self.dismiss(animated: true) {
                self.delegate?.updatePasscode(result: true)
            }
        }else {
            self.hud.dismiss()
            self.dismiss(animated: true) {
                self.delegate?.updatePasscode(result: false)
            }
        }
        
    }
    
}
