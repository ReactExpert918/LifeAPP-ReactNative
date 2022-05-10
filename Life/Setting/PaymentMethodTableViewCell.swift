//
//  PaymentMethodTableViewCell.swift
//  Life
//
//  Created by Yansong Wang on 2022/5/10.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit

class PaymentMethodTableViewCell: UITableViewCell {

    @IBOutlet weak var imageCard: UIImageView!
    
    @IBOutlet weak var labelCardName: UILabel!
    
    @IBOutlet weak var labelCardNumber: UILabel!
    
    @IBOutlet weak var viewEdit: UIView!
    
    @IBOutlet weak var viewMore: UIView!
    
    var edit = false
    
    override func prepareForReuse() {
        self.edit = false
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
    
    
}
