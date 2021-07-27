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

class ZedPaySettingsVC: UIViewController {

    private var tokenPaymentMethod: NotificationToken? = nil
    private var paymentMethods = realm.objects(PaymentMethod.self).filter(falsepredicate)
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

extension ZedPaySettingsVC: UpdatePayDelegateProtocol{
    func updatePasscode(result: Bool) {
        if result {
            self.showSuccessAlert("Successfully updated the passcode")
        } else {
            self.showFailedAlert("Failed to update passcode")
        }
    }
    
    func updateCard(result: Bool) {
        if result {
            self.showSuccessAlert("Successfully added payment method")
        }else{
            self.showFailedAlert("Failed to add payment method")
        }
    }
    
    func deleteCard(result: Bool) {
        if result {
            self.showSuccessAlert("Successfully deleted payment method")
        } else {
            self.showFailedAlert("Failed to delete payment method")
        }
    }
    
    
}
