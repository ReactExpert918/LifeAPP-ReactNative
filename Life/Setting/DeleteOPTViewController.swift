//
//  DeleteOPTViewController.swift
//  Life
//
//  Created by mac on 2021/6/16.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import DPOTPView
import FirebaseAuth
import JGProgressHUD
class DeleteOPTViewController: UIViewController {

    @IBOutlet weak var optView: DPOTPView!
    var delegate: UpdateDataDelegateProtocol? = nil
    let hud = JGProgressHUD(style: .light)
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        optView.becomeFirstResponder()
    }

    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func onSubmitTapped(_ sender: Any) {
        optView.resignFirstResponder()
        let verificationCode = optView.text ?? "123456"
        if verificationCode.count != 6 {
            return
        }
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: verificationCode)
        
        DispatchQueue.main.async {
            self.hud.textLabel.text = ""
            self.hud.show(in: self.view, animated: true)
        }
        Auth.auth().signIn(with: credential) { (authResult, error) in
            self.hud.dismiss()
            if let error = error {
                
                Util.showAlert(vc: self, "Incorrect verification code, please try again.".localized , "")
                return
            }
            
            //DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.dismiss(animated: true) {
                    self.delegate?.deleteAccount()
                }
            //}

        }

    }

}
