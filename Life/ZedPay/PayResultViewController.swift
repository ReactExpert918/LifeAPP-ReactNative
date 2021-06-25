//
//  PayResultViewController.swift
//  Life
//
//  Created by mac on 2021/6/23.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import RealmSwift
class PayResultViewController: UIViewController {

    @IBOutlet weak var labelTransactionId: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    
    @IBOutlet weak var labelPaymenResult: UILabel!
    
    @IBOutlet weak var imagePayResult: UIImageView!
    
    var transactionObjectId = ""
    var transaction: ZEDPay!
    var chatId: String?
    var recipientId: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        labelTransactionId.text = transaction.transId
        labelAmount.text = "¥ " + String(format: "%.2f", transaction.getQuantity())
        if(transaction.status == TRANSACTION_STATUS.SUCCESS){
            labelPaymenResult.text = "Payment Successful".localized
            imagePayResult.image = UIImage(named: "ic_pay_success")
            if(chatId != nil && recipientId != nil){
                Messages.sendMoney(chatId: chatId!, recipientId: recipientId!, payId: transaction.transId, failed: false)
            }
            
        }else if(transaction.status == TRANSACTION_STATUS.FAILED){
            labelPaymenResult.text = "Payment Failed".localized
            imagePayResult.image = UIImage(named: "ic_pay_fail")
            if(chatId != nil && recipientId != nil){
                Messages.sendMoney(chatId: chatId!, recipientId: recipientId!, payId: transaction.transId, failed: true)
            }
        }
        
        
    }
    
    @IBAction func actionTapAgain(_ sender: Any) {
    }
    @IBAction func actionTapDone(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
