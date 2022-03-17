//
//  TransactionDetailViewController.swift
//  Life
//
//  Created by mac on 2021/6/20.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import SwiftyAvatar
class TransactionDetailViewController: UIViewController {

    @IBOutlet weak var imageType: UIImageView!
    @IBOutlet weak var labelAmout: UILabel!
    @IBOutlet weak var labelPaidAt: UILabel!
    
    @IBOutlet weak var imageAvatar: SwiftyAvatar!
    
    @IBOutlet weak var lblSigned: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelPhone: UILabel!
    
    @IBOutlet weak var labelId: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var labelUserType: UILabel!
    
    @IBOutlet weak var labelTransactionType: UILabel!
    
    @IBOutlet weak var uiv_topfee: UIView!
    @IBOutlet weak var lbltopfeeamount: UILabel!
    @IBOutlet weak var uivPaidWith: UIView!
    @IBOutlet weak var lblReceive: UILabel!
    
    @IBOutlet weak var uivStackfee: UIView!
    @IBOutlet weak var lblStackfee: UILabel!
    
    var transaction: ZEDPay!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var person:Person?
        if(transaction.toUserId == transaction.fromUserId){
            self.uivStackfee.isHidden = true
            self.uivPaidWith.isHidden = true
            self.uiv_topfee.isHidden = true
            person = Persons.getById(transaction.fromUserId)
            imageType.image = UIImage(named: "ic_pay_charge")
            labelPaidAt.text = "Added At".localized + " " + Convert.timestampPaid(transaction.updatedAt)
            lblSigned.text = "+"
            labelAmout.text = String(format: "%.2f",Double(transaction.amount)/100.0)
            labelUserType.text = "Balance Received From".localized
            labelTransactionType.text = "Added with ZED Pay".localized
            labelTotal.text = String(format: "%.2f",Double(transaction.amount)/100.0)
            
            
        }else if(transaction.fromUserId == AuthUser.userId()){
            //sent
            self.uivStackfee.isHidden = true
            self.uivPaidWith.isHidden = true
            self.uiv_topfee.isHidden = true
            person = Persons.getById(transaction.toUserId)
            imageType.image = UIImage(named: "ic_sendmoney")
            labelPaidAt.text = "Paid at".localized + " " + Convert.timestampPaid(transaction.updatedAt)
            lblSigned.text = "-"
            labelAmout.text = String(format: "%.2f",transaction.getQuantity() * 100 / 97.5)
            labelUserType.text = "Balance Sent To".localized
            labelTransactionType.text = "Paid with ZED Pay".localized
            labelTotal.text = String(format: "%.2f",transaction.getQuantity() * 100 / 97.5)
            
        }else if(transaction.toUserId == AuthUser.userId()){
            //received
            self.uivStackfee.isHidden = false
            self.uivPaidWith.isHidden = false
            self.uiv_topfee.isHidden = false
            let feeamount = transaction.getQuantity() * 2.5 / 97.5
            self.lbltopfeeamount.text = String(format: "%.2f",feeamount)
            
            self.lblStackfee.text = String(format: "%.2f",feeamount)
            
            person = Persons.getById(transaction.fromUserId)
            imageType.image = UIImage(named: "ic_receive")
            labelPaidAt.text = "Received at".localized + " " + Convert.timestampPaid(transaction.updatedAt)
            lblSigned.text = "+"
            labelAmout.text = String(format: "%.2f",transaction.getQuantity() * 100 / 97.5)
            self.lblReceive.text = String(format: "%.2f",transaction.getQuantity() * 100 / 97.5)
            labelUserType.text = "Balance Received From".localized
            labelTransactionType.text = "Received with ZED Pay".localized
            labelTotal.text = String(format: "%.2f",transaction.getQuantity())
        }
        
        labelId.text = transaction.transId
        labelName.text = person?.getFullName()
        labelPhone.text = person?.phone
        downloadImage(person: person!)
    }
    

    func downloadImage(person: Person) {

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            
            if (error == nil) {
                self.imageAvatar.image = image
                //self.labelInitials.text = nil
            } else{
                self.imageAvatar.image = UIImage(named: "ic_default_profile")
            }
            
        }
    }

}
