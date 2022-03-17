//
//  AddMoneyViewController.swift
//  Life
//
//  Created by mac on 2021/6/29.
//  Copyright © 2021 Zed. All rights reserved.
//
//
//import UIKit
//import JGProgressHUD
//import RealmSwift
//import IQKeyboardManagerSwift
//
//class AddMoneyViewController: UIViewController {
//
//    @IBOutlet weak var col_product: UICollectionView!
//    @IBOutlet weak var btnBalance: RoundButton!
//    let prices = ["5","10","15","20","50","100"]
//    var ds_products = [(String, Bool)]()
//    //var paymentMethod: PaymentMethod?
//    var delegate: UpdatePayDelegateProtocol?
//
//    @IBOutlet weak var lbl_caption: UILabel!
//    @IBOutlet weak var btn_add: RoundButton!
//    let hud = JGProgressHUD(style: .light)
//    private var tokenZEDPay: NotificationToken? = nil
//    private var zedPays = realm.objects(ZEDPay.self).filter(falsepredicate)
//
//    var paymentIndex: Int?
//    var updatedelegate: UpdateBalance?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        initPurchase()
//        setDataSource()
//        updateBtn(self.ds_products)
//        lbl_caption.text = "Add Balance".localized
//        btnBalance.setTitle("Add Balance".localized, for: .normal)
//    }
//
//    func setDataSource() {
//        for i in 0 ... prices.count - 1{
//            self.ds_products.append((prices[i], false))
//        }
//    }
//
//    //MARK: in-app purchase
//    func initPurchase() {
//        IAPHandler.shared.fetchAvailableProducts()
//        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
//            //self?.hideLoadingView()
//            guard let strongSelf = self else{ return }
//            if type == .purchased {
//                if let index = self?.paymentIndex{
//                    self!.hud.show(in: self!.view, animated: true)
//                    var amount: Float = 0
//                    switch index {
//                    case 0:
//                        amount = 5
//                    case 1:
//                        amount = 10
//                    case 2:
//                        amount = 15
//                    case 3:
//                        amount = 20
//                    case 4:
//                        amount = 50
//                    case 5:
//                        amount = 100
//                    default:
//                        amount = 5
//                    }
//                    //let zedPayId = ZEDPays.createAdd(userId: AuthUser.userId(), customerId: self!.paymentMethod!.customerId, cardId: self!.paymentMethod!.cardId, quantity: amount)
//                    let zedPayId = ZEDPays.createAdd(userId: AuthUser.userId(), customerId: "", cardId: "", quantity: amount)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
//                        let predicate = NSPredicate(format: "objectId == %@", zedPayId)
//                        self!.zedPays = realm.objects(ZEDPay.self).filter(predicate)
//                        self!.tokenZEDPay?.invalidate()
//                        self!.zedPays.safeObserve({ changes in
//                            self!.callBack()
//                        }, completion: { token in
//                            self!.tokenZEDPay = token
//                        })
//                    }
//                }
//            }else if type == .restored {
//                let alertView = UIAlertController(title: "Life-App", message: type.message(), preferredStyle: .alert)
//                let action = UIAlertAction(title: "Okay".localized, style: .default, handler: { (alert) in
//                    //TODO: success restored
//                    print("restore succeed")
//                })
//                alertView.addAction(action)
//                strongSelf.present(alertView, animated: true, completion: nil)
//            } else {
//                print(type.message())
//                if let message = type.message(){
//
//                }
//            }
//        }
//    }
//
//    public func presentAlert(from sourceView: UIView, index: Int) {
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        var caption: String = ""
//        if index == 0{
//            caption = "Pay 4.99$ via Apple in-app purchase".localized
//        }else if index == 1{
//            caption = "Pay 9.99$ via Apple in-app purchase".localized
//        }else if index == 2{
//            caption = "Pay 14.99$ via Apple in-app purchase".localized
//        }else if index == 3{
//            caption = "Pay 19.99$ via Apple in-app purchase".localized
//        }else if index == 4{
//            caption = "Pay 49.99$ via Apple in-app purchase".localized
//        }else{
//            caption = "Pay 99.99$ via Apple in-app purchase".localized
//        }
//
//        if let action = self.action(title: caption, index: index) {
//            alertController.addAction(action)
//        }
//        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
//        self.present(alertController, animated: true)
//    }
//
//    private func action(title: String, index: Int) -> UIAlertAction? {
//        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
//            // set index
//            self.paymentIndex = index
//            if index == 0{
//                IAPHandler.shared.purchaseMyProduct(strProductID: LifeProducts.LifeBuy5Points)
//            }else if index == 1{
//                IAPHandler.shared.purchaseMyProduct(strProductID: LifeProducts.LifeBuy10Points)
//            }else if index == 2{
//                IAPHandler.shared.purchaseMyProduct(strProductID: LifeProducts.LifeBuy15Points)
//            }else if index == 3{
//                IAPHandler.shared.purchaseMyProduct(strProductID: LifeProducts.LifeBuy20Points)
//            }else if index == 4{
//                IAPHandler.shared.purchaseMyProduct(strProductID: LifeProducts.LifeBuy50Points)
//            }else{
//                IAPHandler.shared.purchaseMyProduct(strProductID: LifeProducts.LifeBuy100Points)
//            }
//        }
//    }
//
//    @IBAction func actionTapClosed(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func actionTapAdd(_ sender: Any) {
//        for i in 0 ... self.ds_products.count - 1{
//            if self.ds_products[i].1{
//                self.presentAlert(from: self.view, index: i)
//            }
//        }
//    }
//
//    func callBack(){
//        guard let zedPay = zedPays.first else{
//            return
//        }
//
//        if zedPay.status == TRANSACTION_STATUS.PENDING {
//            return
//        }
//
//        if zedPay.status == TRANSACTION_STATUS.FAILED {
//            self.hud.dismiss()
//            let alert = UIAlertController(title: "Error!".localized, message: "", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
//            self.present(alert, animated: true, completion: nil)
//
//        }
//        if zedPay.status == TRANSACTION_STATUS.SUCCESS {
//            self.hud.dismiss()
//
//            let alertView = UIAlertController(title: "Success!".localized, message: "", preferredStyle: .alert)
//            let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
//                self.dismiss(animated: true) {
//                    self.updatedelegate?.updateVal()
//                }
//            })
//            alertView.addAction(action)
//            self.present(alertView, animated: true, completion: nil)
//        }
//    }
//
//    func updateBtn(_ source: [(String, Bool)])  {
//        var isSelected: Bool = false
//        var num = 0
//        for one in source{
//            num += 1
//            if one.1{
//                isSelected = true
//            }
//            if num == source.count{
//                if isSelected{
//                    self.btnBalance.isEnabled = true
//                    self.btnBalance.backgroundColor = AppConstant.PRIMARY_COLOR
//                }else{
//                    self.btnBalance.backgroundColor = .lightGray
//                    self.btnBalance.isEnabled = false
//                }
//            }
//        }
//    }
//}
//
//extension AddMoneyViewController : UICollectionViewDelegate, UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.ds_products.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
//        cell.setDataSource(entity: self.ds_products[indexPath.row])
//        //cell.setDummy()
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        for i in 0 ... self.ds_products.count - 1{
//            self.ds_products[i].1 = false
//        }
//        self.ds_products[indexPath.row].1 = true
//        updateBtn(self.ds_products)
//        self.col_product.reloadData()
//    }
//}
//
//extension AddMoneyViewController: UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let w = collectionView.frame.size.width / 3.0
//        let h: CGFloat = 100
//        return CGSize(width: w, height: h)
//    }
//}
//
//class ProductCell: UICollectionViewCell {
//
//    @IBOutlet weak var lbl_price: UILabel!
//    @IBOutlet weak var uiv_total: UIView!
//
//    func setDataSource(entity: (String, Bool)) {
//        self.lbl_price.text = entity.0
//        if entity.1{
//            self.uiv_total.backgroundColor = AppConstant.PRIMARY_COLOR
//        }else{
//            self.uiv_total.backgroundColor = .lightGray
//        }
//    }
//}

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
    @IBAction func actionTapAddMoney(_ sender: Any) {
        guard let quantityString = addAmount.text as NSString? else {
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
            let alert = UIAlertController(title: "Error!".localized, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }

        if zedPay.status == TRANSACTION_STATUS.SUCCESS {
            self.hud.dismiss()

            let alertView = UIAlertController(title: "Success!".localized, message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self.dismiss(animated: true, completion: nil)
            })
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
        }
    }
}
