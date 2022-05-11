//
//  PaymentMethodTableViewCell.swift
//  Life
//
//  Created by Yansong Wang on 2022/5/10.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit

protocol PaymentCellDelegate {
    func onDeleteCard()
}

class PaymentMethodTableViewCell: UITableViewCell {

    @IBOutlet weak var imageCard: UIImageView!
    
    @IBOutlet weak var labelCardName: UILabel!
    
    @IBOutlet weak var labelCardNumber: UILabel!
    
    @IBOutlet weak var viewEdit: UIView!
    
    @IBOutlet weak var viewMore: UIView!
    
    var edit = false
    
    var delegate: PaymentCellDelegate?
    
    override func prepareForReuse() {
        self.edit = false
        self.viewMore.isHidden = false
        self.viewEdit.isHidden = true
        self.labelCardName.alpha = 0
        self.labelCardNumber.alpha = 0
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func actionUpdate(_ sender: Any) {
        self.edit = false
        self.onEdit()
    }
    
    @IBAction func actionRemove(_ sender: Any) {
        self.edit = false
        self.onEdit()
        if let delegate = self.delegate {
            delegate.onDeleteCard()
        }
    }
    
    @IBAction func actionEdit(_ sender: Any) {
        self.edit = true
        self.onEdit()
    }
    
    func onEdit() {
        if self.edit {
            self.viewEdit.isHidden = false
            self.viewMore.isHidden = true
        } else {
            self.viewEdit.isHidden = true
            self.viewMore.isHidden = false
        }
    }
    
    func configure(with payment: PaymentMethod) {
        self.labelCardName.alpha = 1
        self.labelCardNumber.alpha = 1
        if payment.cardBrand == "visa" {
            self.labelCardName.text = "Visa"
            self.labelCardNumber.text = "**** \(payment.cardNumber)"
            self.imageCard.image = UIImage(named: "ic_card_visa")
        } else if payment.cardBrand == "amex" {
            self.labelCardName.text = "Amex"
            self.labelCardNumber.text = "**** \(payment.cardNumber)"
            self.imageCard.image = UIImage(named: "ic_card_amex")
        } else if payment.cardBrand == "mastercard" {
            self.labelCardName.text = "Master Card"
            self.labelCardNumber.text = "**** \(payment.cardNumber)"
            self.imageCard.image = UIImage(named: "ic_card_mastercard")
        } else if payment.cardBrand == "maestro" {
            self.labelCardName.text = "Maestro"
            self.labelCardNumber.text = "**** \(payment.cardNumber)"
            self.imageCard.image = UIImage(named: "ic_card_maestro")
        } else if payment.cardBrand == "diners" {
            self.labelCardName.text = "Diners Club"
            self.labelCardNumber.text = "**** \(payment.cardNumber)"
            self.imageCard.image = UIImage(named: "ic_card_dinersclub")
        } else if payment.cardBrand == "discover" {
            self.labelCardName.text = "Discover"
            self.labelCardNumber.text = "**** \(payment.cardNumber)"
            self.imageCard.image = UIImage(named: "ic_card_discovery")
        } else if payment.cardBrand == "unionpay" {
            self.labelCardName.text = "UnionPay"
            self.labelCardNumber.text = "**** \(payment.cardNumber)"
            self.imageCard.image = UIImage(named: "ic_card_unionpay")
        } else if payment.cardBrand == "mir" {
            self.labelCardName.text = "Mir"
            self.labelCardNumber.text = "**** \(payment.cardNumber)"
            self.imageCard.image = UIImage(named: "ic_card_mir")
        } else if payment.cardBrand == "jcb" {
            self.labelCardName.text = "Jcb"
            self.labelCardNumber.text = "**** \(payment.cardNumber)"
            self.imageCard.image = UIImage(named: "ic_card_jcb")
        } else {
            self.labelCardName.text = "Unknown"
            self.labelCardNumber.text = "**** \(payment.cardNumber)"
        }
    }
}
