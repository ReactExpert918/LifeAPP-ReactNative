//
//  TransactionCell.swift
//  Life
//
//  Created by mac on 2021/6/18.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import SwiftyAvatar
class TransactionCell: UITableViewCell {

    @IBOutlet weak var imageUser: SwiftyAvatar!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageType: UIImageView!
    
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelQuantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //contentView.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        //contentView.backgroundColor = UIColor.clear
    }
    
    class func GetCellReuseIdentifier() -> String {
        return "transactionCell"
    }
    
    class func Register(withTableView tableView:UITableView) {
        tableView.register(self.GetCellNib(), forCellReuseIdentifier: self.GetCellReuseIdentifier())
    }
    
    class func GetCellNib() -> UINib {
        let aNib = UINib.init(nibName: "TransactionCell",bundle: Bundle.main);
        return aNib
    }
    
    func bindData(transaction: ZEDPay, tableView: UITableView, indexPath: IndexPath) {
        
        if(transaction.toUserId == transaction.fromUserId){
            let person = Persons.getById(transaction.fromUserId)
            imageType.image = UIImage(named: "ic_pay_charge")
            labelType.text = "Add Money"
            labelQuantity.text = "+" + String(format: "%.2f",Double(transaction.amount)/100.0)+"¥"
            labelName.text = person?.fullname
            downloadImage(person: person!, tableView: tableView, indexPath: indexPath)
        }else if(transaction.fromUserId == AuthUser.userId()){
            //sent
            let person = Persons.getById(transaction.toUserId)
            imageType.image = UIImage(named: "ic_pay_sent")
            labelType.text = "Money Sent"
            labelQuantity.text = "-" + String(format: "%.2f",transaction.getQuantity())+"¥"
            labelName.text = person?.fullname
            downloadImage(person: person!, tableView: tableView, indexPath: indexPath)
            
        }else if(transaction.toUserId == AuthUser.userId()){
            //received
            let person = Persons.getById(transaction.fromUserId)
            imageType.image = UIImage(named: "ic_pay_received")
            labelType.text = "Money Received"
            labelQuantity.text = "+" + String(format: "%.2f",transaction.getQuantity())+"¥"
            labelName.text = person?.fullname
            downloadImage(person: person!, tableView: tableView, indexPath: indexPath)
        }
        
        
        
    }
    
    func downloadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            let indexSelf = tableView.indexPath(for: self)
            if ((indexSelf == nil) || (indexSelf == indexPath)) {
                if (error == nil) {
                    self.imageUser.image = image
                    //self.labelInitials.text = nil
                } else{
                    self.imageUser.image = UIImage(named: "ic_default_profile")
                }
            }
        }
    }
 
}
