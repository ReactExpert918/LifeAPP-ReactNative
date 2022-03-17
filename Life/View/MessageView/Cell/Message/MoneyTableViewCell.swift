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
    
    @IBOutlet weak var imgAvatarMe: UIImageView!
    @IBOutlet weak var imgAvatarYou: UIImageView!
    
    @IBOutlet weak var viewStateMe: UIView!
    @IBOutlet weak var viewStateYou: UIView!
    
    @IBOutlet weak var viewContainer: ExtensionView!
    
    var zedPay: ZEDPay?
    var message: Message?
    var messageView: ChatViewController?
    var fliped = false
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
    
    func bindData(_ message: Message, messageView: ChatViewController, indexPath: IndexPath) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionContentView))
        contentView.addGestureRecognizer(tapGesture)
        self.messageView = messageView
        imgAvatarMe.image = messageView.avatarImage(indexPath)
        imgAvatarYou.image = messageView.avatarImage(indexPath)
        
        viewStateYou.layer.cornerRadius = 6
        viewStateYou.layer.borderWidth = 2
        viewStateYou.layer.borderColor = UIColor.white.cgColor
        
        viewStateMe.layer.cornerRadius = 6
        viewStateMe.layer.borderWidth = 2
        viewStateMe.layer.borderColor = UIColor.white.cgColor
        
        if let trans_id = message.text.split(separator: "$").first{
            let predicate = NSPredicate(format: "transId == %@ ", String(trans_id))
            zedPay = realm.objects(ZEDPay.self).filter(predicate).first
            
            if(zedPay?.fromUserId == AuthUser.userId()){ // sent
                sendDirection.image = UIImage(named: "ic_balance_sent")
                moneyQuantity.text = ((zedPay?.getQuantity() ?? 0) * 100 / 97.5).moneyString()
                labelPayResult.text = "Balance sent successfully".localized
                imgAvatarMe.isHidden = false
                viewStateMe.isHidden = false
                
                imgAvatarYou.isHidden = true
                viewStateYou.isHidden = true
                self.flipContainer()
            }else{ // received
                sendDirection.image = UIImage(named: "ic_balance_receive")
                moneyQuantity.text = zedPay?.getQuantity().moneyString()
                labelPayResult.text = "Balance received successfully".localized
                imgAvatarMe.isHidden = true
                viewStateMe.isHidden = true
                
                imgAvatarYou.isHidden = false
                viewStateYou.isHidden = false
            }
            //labelPayResult.text = message.isMediaFailed ? "Payment Failed".localized : "Payment Successful".localized
            if zedPay?.status == TRANSACTION_STATUS.FAILED{
                labelPayResult.text = "Payment Failed".localized
            }
            imagePayResult.image = message.isMediaFailed ? UIImage(named: "ic_pay_fail") : UIImage(named: "ic_pay_success")
            sendDate.text = Convert.timestampToDayTime(message.createdAt)
        }
    }
    
    func flipContainer() {
        if self.fliped {
            return
        }
        self.fliped = true
        self.viewContainer.flipX()
        for v in self.viewContainer.subviews {
            if v.tag != 0 {
                v.flipX()
            }
        }
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
