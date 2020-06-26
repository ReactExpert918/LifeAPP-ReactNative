//
//  FriendCell.swift
//  Life
//
//  Created by Jaelhorton on 6/26/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    class func GetCellReuseIdentifier() -> String {
        return "friendCell"
    }
    
    class func Register(withTableView tableView:UITableView) {
        tableView.register(self.GetCellNib(), forCellReuseIdentifier: self.GetCellReuseIdentifier())
    }
    
    class func GetCellNib() -> UINib {
        let aNib = UINib.init(nibName: "FriendCell",bundle: Bundle.main);
        return aNib
    }
}
