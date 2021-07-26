//
//  UserCell.swift
//  Life
//
//  Created by Good Developer on 7/23/21.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var imvProfile: UIImageView! { didSet {
        imvProfile.activityIndicator = .activity
        imvProfile.activityIndicatorColor = .black
    }}
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(_ person: Person) {
        
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            if (error == nil) {
                self.imvProfile.image = image
            } else {
                self.imvProfile.image = UIImage(named: "ic_default_profile")
            }
        }
        
        lblName.text   = person.fullname
        lblDetail.text = person.about
    }

}
