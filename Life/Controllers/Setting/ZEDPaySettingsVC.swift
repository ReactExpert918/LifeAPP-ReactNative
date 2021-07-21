//
//  StripeSettingsViewController.swift
//  Life
//
//  Created by mac on 2021/6/27.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import JGProgressHUD
import FittedSheets
import RealmSwift

protocol UpdatePayDelegateProtocol {
    func updatePasscode(result: Bool)
    func updateCard(result: Bool)
    func deleteCard(result: Bool)
}

class ZEDPaySettingsVC: UIViewController {

    @IBOutlet weak var labelResult: UILabel!
    @IBOutlet weak var imgPopup: UIImageView!
    @IBOutlet weak var resultView: UIView!
    
    private var tokenPaymentMethod: NotificationToken? = nil
    private var paymentMethods = realm.objects(PaymentMethod.self).filter(falsepredicate)
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resultView.isHidden = true
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let predicate = NSPredicate(format: "userId == %@ AND status == %@ AND isDeleted == NO", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
        paymentMethods = realm.objects(PaymentMethod.self).filter(predicate)
    }
    

    @IBAction func actionTapClosed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionTapAddCard(_ sender: Any) {
        if let paymentMethod = paymentMethods.first {
            let vc =  self.storyboard?.instantiateViewController(identifier: "removePaymentVC") as! RemovePaymentVC
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            vc.paymentMethod = paymentMethod
            self.present(vc, animated: false, completion: nil)
        }else{
            let vc =  self.storyboard?.instantiateViewController(identifier: "addPaymentVC") as! AddPaymentMethodVC
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            
            self.present(vc, animated: false, completion: nil)
        }
        
        
    }
    @IBAction func actionTapPasscode(_ sender: Any) {
        let vc =  self.storyboard?.instantiateViewController(identifier: "UpdatePasscodeVC") as! UpdatePasscodeVC
        vc.delegate = self
        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(360)])
        self.present(sheetController, animated: false, completion: nil)
    }
    
}

extension ZEDPaySettingsVC: UpdatePayDelegateProtocol{
    func updatePasscode(result: Bool) {
        if result==false {
            self.imgPopup.image = UIImage(named: "ic_pay_fail")
            self.labelResult.text = "Update passcode failed"
        }else{
            
            self.imgPopup.image = UIImage(named: "ic_checkmark_success")
            self.labelResult.text = "Successfully updated the passcode"
        }
       
        
        self.resultView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.resultView.isHidden = true
        }
    }
    
    func updateCard(result: Bool) {
        if result==false {
            self.imgPopup.image = UIImage(named: "ic_pay_fail")
            self.labelResult.text = "Add payment method failed"
        }else{
            
            self.imgPopup.image = UIImage(named: "ic_checkmark_success")
            self.labelResult.text = "Successfully add payment method"
        }
       
        
        self.resultView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.resultView.isHidden = true
        }
    }
    
    func deleteCard(result: Bool) {
        if result==false {
            self.imgPopup.image = UIImage(named: "ic_pay_fail")
            self.labelResult.text = "Delete payment method failed"
        }else{
            
            self.imgPopup.image = UIImage(named: "ic_checkmark_success")
            self.labelResult.text = "Successfully delete payment method"
        }
       
        
        self.resultView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.resultView.isHidden = true
        }
    }
    
    
}
