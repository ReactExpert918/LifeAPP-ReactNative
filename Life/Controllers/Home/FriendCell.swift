//
//  FriendCell.swift
//  Life
//
//  Created by Jaelhorton on 6/26/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import SwiftyAvatar
class FriendCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: SwiftyAvatar!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func bindData(person: Person) {

        userNameLabel.text = person.fullname
    }

    func bindGroupData(group: Group) {

        userNameLabel.text = group.name
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {
/*
        if let path = MediaDownload.pathUser(person.objectId) {
            profileImageView.image = UIImage.image(path, size: 40)
            //labelInitials.text = nil
        } else {
            profileImageView.image = nil
            //labelInitials.text = person.initials()
            downloadImage(person: person, tableView: tableView, indexPath: indexPath)
        }
*/
        downloadImage(person: person, tableView: tableView, indexPath: indexPath)
    }
    func loadGroupImage(group: Group, tableView: UITableView, indexPath: IndexPath) {
    /*
            if let path = MediaDownload.pathUser(person.objectId) {
                profileImageView.image = UIImage.image(path, size: 40)
                //labelInitials.text = nil
            } else {
                profileImageView.image = nil
                //labelInitials.text = person.initials()
                downloadImage(person: person, tableView: tableView, indexPath: indexPath)
            }
    */
            downloadGroupImage(group: group, tableView: tableView, indexPath: indexPath)
        }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func downloadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {

        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            let indexSelf = tableView.indexPath(for: self)
            if ((indexSelf == nil) || (indexSelf == indexPath)) {
                if (error == nil) {
                    self.profileImageView.image = image
                    //self.labelInitials.text = nil
                } else{
                    self.profileImageView.image = UIImage(named: "ic_default_profile")
                }
            }
        }
    }
    
    func downloadGroupImage(group: Group, tableView: UITableView, indexPath: IndexPath) {

        MediaDownload.startGroup(group.objectId, pictureAt: group.pictureAt) { image, error in
            let indexSelf = tableView.indexPath(for: self)
            if ((indexSelf == nil) || (indexSelf == indexPath)) {
                if (error == nil) {
                    self.profileImageView.image = image
                    //self.labelInitials.text = nil
                } else{
                    self.profileImageView.image = UIImage(named: "ic_default_profile")
                }
            }
        }
    }
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
