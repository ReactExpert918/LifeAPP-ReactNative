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
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelPhone: UILabel!
    
    @IBOutlet weak var labelId: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var labelUserType: UILabel!
    
    @IBOutlet weak var labelTransactionType: UILabel!
    
    var transaction: Transaction!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var person:Person?
        if(transaction.fromUserId == AuthUser.userId()){
            //sent
            person = Persons.getById(transaction.toUserId)
            imageType.image = UIImage(named: "ic_pay_send_large")
            labelPaidAt.text = "Paid at".localized + " " + Convert.timestampPaid(transaction.updatedAt)
            labelAmout.text = "-¥ " + String(format: "%.2f",transaction.getQuantity())
            labelUserType.text = "Money Sent To".localized
            labelTransactionType.text = "Paid with ZED Pay".localized

            
        }else{
            //received
            person = Persons.getById(transaction.fromUserId)
            imageType.image = UIImage(named: "ic_pay_receive_large")
            labelPaidAt.text = "Received at".localized + " " + Convert.timestampPaid(transaction.updatedAt)
            
            labelAmout.text = "+¥ " + String(format: "%.2f",transaction.getQuantity())
            labelUserType.text = "Money Received From".localized
            labelTransactionType.text = "Received with ZED Pay".localized
        }
        
        labelTotal.text = "¥ " + String(format: "%.2f",transaction.getQuantity())
        labelId.text = transaction.objectId
        labelName.text = person?.fullname
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
