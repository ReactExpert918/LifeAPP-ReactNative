//
//  AddMoneyViewController.swift
//  Life
//
//  Created by mac on 2021/6/29.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import JGProgressHUD
import RealmSwift
import IQKeyboardManagerSwift

class AddMoneyViewController: UIViewController {

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

    var paymentIndex: Int?
    
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
        
        initPurchase()
    }
    
    //MARK: in-app purchase
    func initPurchase() {
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            //self?.hideLoadingView()
            guard let strongSelf = self else{ return }
            if type == .purchased {
                let alertView = UIAlertController(title: "Life", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "Okay", style: .default, handler: { (alert) in
                    // TODO: payment process
                    if let index = self?.paymentIndex{
                        self!.hud.show(in: self!.view, animated: true)
                        var amount: Float = 0
                        switch index {
                        case 0:
                            amount = 500
                        case 1:
                            amount = 1000
                        case 2:
                            amount = 5000
                        case 3:
                            amount = 10000
                        default:
                            amount = 500
                        }
                        let zedPayId = ZEDPays.createAdd(userId: AuthUser.userId(), customerId: self!.paymentMethod!.customerId, cardId: self!.paymentMethod!.cardId, quantity: amount)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                            let predicate = NSPredicate(format: "objectId == %@", zedPayId)
                            self!.zedPays = realm.objects(ZEDPay.self).filter(predicate)
                            self!.tokenZEDPay?.invalidate()
                            self!.zedPays.safeObserve({ changes in
                                self!.callBack()
                            }, completion: { token in
                                self!.tokenZEDPay = token
                            })
                        }
                    }
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            
            } else if type == .restored {
                let alertView = UIAlertController(title: "Life", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "Okay", style: .default, handler: { (alert) in
                    //TODO: success restored
                    print("restore succeed")
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            } else {
                print(type.message())
                if let message = type.message(){
                    
                }
            }
        }
    }
    
    public func presentAlert(from sourceView: UIView, index: Int) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let action = self.action(title: "ApplePayで支払う", index: index) {
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
    
    private func action(title: String, index: Int) -> UIAlertAction? {
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            // set index
            self.paymentIndex = index
            if index == 0{
                IAPHandler.shared.purchaseMyProduct(strProductID: LifeProducts.LifeBuy5Points)
            }else if index == 1{
                IAPHandler.shared.purchaseMyProduct(strProductID: LifeProducts.LifeBuy10Points)
            }else if index == 2{
                IAPHandler.shared.purchaseMyProduct(strProductID: LifeProducts.LifeBuy50Points)
            }else{
                IAPHandler.shared.purchaseMyProduct(strProductID: LifeProducts.LifeBuy100Points)
            }
        }
    }
    
    @IBAction func actionTapClosed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionTapRemove(_ sender: Any) {
        self.presentAlert(from: self.view, index: 0)
        /*guard let quantityString = addAmount.text as NSString? else {
            return
        }
        
        if(quantityString.floatValue <= 0.5){
            let alert = UIAlertController(title: "Error!".localized, message: "The amount must be greater than 0.5".localized, preferredStyle: .alert)
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
        }*/
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
            let alert = UIAlertController(title: "Error!".localized, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        if zedPay.status == TRANSACTION_STATUS.SUCCESS {
            self.hud.dismiss()
            let alert = UIAlertController(title: "Success!".localized, message: "".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
