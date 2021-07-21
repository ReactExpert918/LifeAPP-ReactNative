//
//  ForgotPasswordVC.swift
//  Life
//
//  Created by Lukas Bimba on 9/18/20.
//  Copyright © 2020 Zed. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ForgotPasswordVC: BaseVC {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendPasswordReset(_ sender: Any) {
        if checkValid() {
            doResetAction()
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
        
        return true
    }
    
    fileprivate func doResetAction() {
        showProgress()
        
        Auth.auth().sendPasswordReset(withEmail: self.txtEmail.text!, completion: { (error) in
            self.hideProgress()
            var title = ""
            var message = ""
            
            if error != nil {
                title = R.titleError
                message = R.errFailedReset
            } else {
                title = R.titleSuccess
                message = R.altResetSent
                self.txtEmail.text! = ""
            }
            
            self.showAlert(title, message: message, positive: R.btnOk, negative: nil)
        })
    }

    // Hide Keyboard when User Touches Outside of Keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ForgotPasswordVC: UITextFieldDelegate {
    // MARK: - UITextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == txtEmail) {
            if (checkValid()) {
                doResetAction()
            }
        }
        
        textField.resignFirstResponder()
        return false
    }
}
