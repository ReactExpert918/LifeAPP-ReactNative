//
//  HomeCell.swift
//  Life
//
//  Created by Good Developer on 7/23/21.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class HomeCell: UITableViewCell {

    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setFriend(_ person: Person) {
        lblName.text = person.fullname
        
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.imvProfile.image = image
                //self.labelInitials.text = nil
            } else {
                self.imvProfile.image = UIImage(named: "ic_default_profile")
            }
        }
    }
    
    func setGroup(_ group: Group) {
        lblName.text = group.name
        
        MediaDownload.startGroup(group.objectId, pictureAt: group.pictureAt) { image, error in
            if (error == nil) {
                self.imvProfile.image = image
            } else{
                self.imvProfile.image = UIImage(named: "ic_default_profile")
            }
        }
    }

}
