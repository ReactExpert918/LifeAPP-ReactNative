//
//  SearchFriendCell.swift
//  Life
//
//  Created by Yun Li on 2020/6/27.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import Foundation
import UIKit
class SearchFriendCell : UITableViewCell{
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    var index: Int!
    var callbackAddFriend: ((_ index: Int) -> ())?
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func bindData(person: Person) {

        userNameLabel.text = person.fullname
        phoneNumberLabel.text = person.phone
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {

        if let path = MediaDownload.pathUser(person.objectId) {
            profileImageView.image = UIImage.image(path, size: 40)
            //labelInitials.text = nil
        } else {
            profileImageView.image = nil
            //labelInitials.text = person.initials()
            downloadImage(person: person, tableView: tableView, indexPath: indexPath)
        }
        profileImageView.makeRounded()

    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func downloadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            let indexSelf = tableView.indexPath(for: self)
            if ((indexSelf == nil) || (indexSelf == indexPath)) {
                if (error == nil) {
                    self.profileImageView.image = image?.square(to: 40)
                    //self.labelInitials.text = nil
                } else if (error  != nil) {
                    self.profileImageView.image = UIImage(named: "ic_default_profile")
                }
            }
        }
    }
    @IBAction func addFriendTapped(_ sender: Any) {
        callbackAddFriend?(index)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


