//
//  PayBottomSheetViewController.swift
//  Life
//
//  Created by mac on 2021/6/20.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import SwiftyAvatar
import JGProgressHUD
class PayBottomSheetViewController: UIViewController {
    var isFriend : Bool = false
    var person: Person!
    var qrCode : String!
    var qrView : PayQRCodeViewController!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var profile: SwiftyAvatar!
    @IBOutlet weak var addFriendButton: RoundButton!
    @IBOutlet weak var labelBalance: UILabel!
    @IBOutlet weak var inputAmount: UITextField!
    
    let hud = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        name.text = person.fullname
        
        phoneNumber.text = person.phone
    
        if(person.objectId == AuthUser.userId() || Friends.isFriend(person.objectId)){
            //addFriendButton.isHidden = true
            
            checkMark.isHidden = false
        }else{
            checkMark.isHidden = true
            addFriendButton.isHidden = false
        }
        labelBalance.text = "¥" + String(format: "%.2f", person.getBalance())
            
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.profile.image = image
            }
            else {
                self.profile.image = UIImage(named: "ic_default_profile")
            }
            self.view.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) { // As soon as vc appears
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    @IBAction func onCancelTapped(_ sender: Any) {
        dismiss(animated: true, completion:  nil)
    }
    
    @IBAction func onAddFriendTapped(_ sender: Any) {
        
        /// send
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        qrView.qrReader.startScanning()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if(inputAmount.text == "0"){
            inputAmount.text = ""
        }
    }
    @objc func keyboardWillHide(_ notification: Notification?) {
        if(inputAmount.text == ""){
            inputAmount.text = "0"
        }
        
    }
    

}
