//
//  PassPayVC.swift
//  Life
//
//  Created by mac on 2021/6/23.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import DPOTPView
import JGProgressHUD
import RealmSwift

class PassPayVC: UIViewController {
    weak var pvc : UIViewController?
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var imageNext: UIImageView!
    @IBOutlet weak var dpPassCode: DPOTPView!
    
    private var tokenTransactions: NotificationToken? = nil
    private var transactions = realm.objects(ZEDPay.self).filter(falsepredicate)
    
    let hud = JGProgressHUD(style: .light)
    var toUserId: String = ""
    var quantity: Float = 0
    var updating = false
    var transactionObjectId = ""
    
    
    var chatId: String?
    var recipientId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        dpPassCode.dpOTPViewDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        checkValidation(text: dpPassCode.text ?? "")
    }
    
    //MARK:- check validation
    func checkValidation(text: String){
       if(text.count == 4){
           nextButton.backgroundColor = UIColor(hexString: "#16406F")
           imageNext.tintColor = .white
        nextButton.isUserInteractionEnabled = true
       }
       else{
        nextButton.isUserInteractionEnabled = false
           nextButton.backgroundColor = UIColor(white: 0, alpha: 0.17)
           imageNext.tintColor = UIColor(white: 0, alpha: 0.31)
       }
   }
    
    // MARK: - keyboard layout
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            nextBottomContraint.constant = keyboardHeight + 30
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if let _: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            nextBottomContraint.constant = 30
        }
    }
    //MARK:- close
    @IBAction func actionClose(_ sender: Any) {
        if(updating == false){
            self.dismiss(animated: true, completion: nil)
        }
    }
    // MARK: - next tap
    @IBAction func actionTapNext(_ sender: Any) {
        let passCode = dpPassCode.text ?? ""
        
        let predicate = NSPredicate(format: "userId == %@ AND status == %@ ", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
        let customers = realm.objects(StripeCustomer.self).filter(predicate)
        guard let customer = customers.first else{
            return
        }
        if(passCode != customer.passcode.decryptedString()){
            let confirmationAlert = UIAlertController(title: "", message: "PassCode incorrect", preferredStyle: .alert)
            confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(confirmationAlert, animated: true, completion: nil)
        }else{
            self.hud.textLabel.text = "Sending Money..."
            self.hud.show(in: self.view, animated: true)
            self.updating = true
            self.transactionObjectId = ZEDPays.create(fromUserId: (Persons.currentPerson()?.objectId)!, toUserId: toUserId, quantity: quantity)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                let predicate = NSPredicate(format: "objectId == %@", self.transactionObjectId )
                self.transactions = realm.objects(ZEDPay.self).filter(predicate)
                self.tokenTransactions?.invalidate()
                self.transactions.safeObserve({ changes in
                    self.callBack()
                }, completion: { token in
                    self.tokenTransactions = token
                })
            }
            
        }
    }
    
    //MARK: - Transcation callback
    func callBack(){
        
        guard let transaction = self.transactions.first else{
            return
        }
        if transaction.status == TRANSACTION_STATUS.PENDING{
            return
        }
        self.hud.dismiss()
        
        self.updating = false
        
        
        weak var pvc = self.presentingViewController
        self.dismiss(animated: false, completion: {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "payResultVC") as! PayResultVC
            vc.transaction = self.transactions.first!
            vc.chatId = self.chatId
            vc.recipientId = self.recipientId
            vc.modalPresentationStyle = .fullScreen
            pvc?.present(vc, animated: true)
        })
        
    }

}
extension PassPayVC : DPOTPViewDelegate {
   func dpOTPViewAddText(_ text: String, at position: Int) {
        //// print("addText:- " + text + " at:- \(position)" )
        self.checkValidation(text: text)
    }
    
    func dpOTPViewRemoveText(_ text: String, at position: Int) {
        //// print("removeText:- " + text + " at:- \(position)" )
        self.checkValidation(text: text)
    }
    
    func dpOTPViewChangePositionAt(_ position: Int) {
        // print("at:-\(position)")
    }
    func dpOTPViewBecomeFirstResponder() {
        
    }
    func dpOTPViewResignFirstResponder() {
        
    }
}
