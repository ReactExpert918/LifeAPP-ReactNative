//
//  AddMoneyVC.swift
//  Life
//
//  Created by mac on 2021/6/29.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import JGProgressHUD
import RealmSwift

class AddMoneyVC: UIViewController {

    @IBOutlet weak var imageCard: UIImageView!
    var paymentMethod: PaymentMethod?
    var delegate: UpdatePayDelegateProtocol?
    
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var carExp: UILabel!
    @IBOutlet weak var cardImage: UIImageView!
    
    @IBOutlet weak var addAmount: UITextField!
    @IBOutlet weak var cardCVC: UILabel!
    let hud = JGProgressHUD(style: .light)
    private var tokenZEDPay: NotificationToken? = nil
    private var zedPays = realm.objects(ZEDPay.self).filter(falsepredicate)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if paymentMethod?.cardBrand == "visa" {
            cardImage.image = UIImage(named: "ic_card_visa")
        } else if paymentMethod?.cardBrand == "amex"{
            cardImage.image = UIImage(named: "ic_card_amex")
        } else if paymentMethod?.cardBrand == "mastercard"{
            cardImage.image = UIImage(named: "ic_card_mastercard")
        } else if paymentMethod?.cardBrand == "diners"{
            cardImage.image = UIImage(named: "ic_card_dinersclub")
        } else if paymentMethod?.cardBrand == "discover"{
            cardImage.image = UIImage(named: "ic_card_discovery")
        } else if paymentMethod?.cardBrand == "unionpay"{
            cardImage.image = UIImage(named: "ic_card_unionpay")
        } else if paymentMethod?.cardBrand == "jcb"{
            cardImage.image = UIImage(named: "ic_card_jcb")
        } else{
            cardImage.isHidden = true
        }
        
        cardNumber.text = "**** **** **** " + paymentMethod!.cardNumber
        carExp.text = paymentMethod!.expMonth+"/"+paymentMethod!.expYear
        cardCVC.text = paymentMethod?.cvc
        
        addAmount.becomeFirstResponder()
    }
    

    @IBAction func actionTapClosed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func actionTapRemove(_ sender: Any) {
        guard let quantityString = addAmount.text as NSString? else {
            return
        }
        
        if(quantityString.floatValue <= 0.5){
            let alert = UIAlertController(title: "Error!", message: "The amount must be greater than 0.5", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            self.hud.show(in: self.view, animated: true)
        
            let zedPayId = ZEDPays.createAdd(userId: AuthUser.userId(), customerId: paymentMethod!.customerId, cardId: paymentMethod!.cardId, quantity: quantityString.floatValue)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                let predicate = NSPredicate(format: "objectId == %@", zedPayId)
                self.zedPays = realm.objects(ZEDPay.self).filter(predicate)
                self.tokenZEDPay?.invalidate()
                self.zedPays.safeObserve({ changes in
                    self.callBack()
                }, completion: { token in
                    self.tokenZEDPay = token
                })
            }
        }
        
    }
    
    func callBack(){
        guard let zedPay = zedPays.first else{
            return
        }
        
        if zedPay.status == TRANSACTION_STATUS.PENDING {
            return
        }
        
        if zedPay.status == TRANSACTION_STATUS.FAILED {
            self.hud.dismiss()
            let alert = UIAlertController(title: "Error!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        if zedPay.status == TRANSACTION_STATUS.SUCCESS {
            self.hud.dismiss()
            let alert = UIAlertController(title: "Success!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
