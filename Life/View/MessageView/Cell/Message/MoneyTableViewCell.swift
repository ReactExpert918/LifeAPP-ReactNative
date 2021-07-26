//
//  MoneyTableViewCell.swift
//  Life
//
//  Created by mac on 2021/6/25.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import Realm
class MoneyTableViewCell: UITableViewCell {

    @IBOutlet weak var moneyQuantity: UILabel!
    @IBOutlet weak var sendDirection: UIImageView!
    @IBOutlet weak var sendDate: UILabel!
    @IBOutlet weak var labelPayResult: UILabel!
    @IBOutlet weak var imagePayResult: UIImageView!
    
    var zedPay: ZEDPay?
    var message: Message?
    var messageView: ChatViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func actionTapView(_ sender: Any) {
        messageView?.goPayDetail(zedPay!)
    }
    
    func bindData(_ message: Message, messageView: ChatViewController) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionContentView))
        contentView.addGestureRecognizer(tapGesture)
        self.messageView = messageView
        
        
        let predicate = NSPredicate(format: "transId == %@ ", message.text)
        zedPay = realm.objects(ZEDPay.self).filter(predicate).first
        
        if(zedPay?.fromUserId == AuthUser.userId()){
            sendDirection.image = UIImage(named: "ic_pay_sent")
        }else{
            sendDirection.image = UIImage(named: "ic_pay_received")
        }
        labelPayResult.text = message.isMediaFailed ? "Payment Failed" : "Payment Successful"
        imagePayResult.image = message.isMediaFailed ? UIImage(named: "ic_pay_fail") : UIImage(named: "ic_pay_success")
        
        moneyQuantity.text = zedPay?.getQuantity().moneyString()
        sendDate.text = Convert.timestampToDayTime(message.createdAt)
        
    }
    
    class func GetCellReuseIdentifier() -> String {
        return "moneyCell"
    }
    
    class func Register(withTableView tableView:UITableView) {
        tableView.register(self.GetCellNib(), forCellReuseIdentifier: self.GetCellReuseIdentifier())
    }
    
    class func GetCellNib() -> UINib {
        let aNib = UINib.init(nibName: "MoneyTableViewCell",bundle: Bundle.main);
        return aNib
    }
    @objc func actionContentView() {

        self.messageView?.dismissKeyboard()
        //messagesView.actionTapBubble(indexPath)
    }

    
}
