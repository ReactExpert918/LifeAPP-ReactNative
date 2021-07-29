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
    
    var chatVCProtocol: ChatViewControllerProtocol!
    var indexPath: IndexPath!
    var group: Group!
    var cellType = 0
    
    @IBOutlet weak var profileImageView: SwiftyAvatar!
    @IBOutlet weak var userNameLabel: UILabel!
    
    func bindData(person: Person, indexPath: IndexPath) {

        userNameLabel.text = person.fullname
        cellType = 0
        self.indexPath = indexPath
    }

    func bindGroupData(group: Group, indexPath: IndexPath) {

        userNameLabel.text = group.name
        cellType = 1
        self.indexPath = indexPath
        self.group = group
    }

    func loadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {
        downloadImage(person: person, tableView: tableView, indexPath: indexPath)
    }
    
    func loadGroupImage(group: Group, tableView: UITableView, indexPath: IndexPath) {
        downloadGroupImage(group: group, tableView: tableView, indexPath: indexPath)
    }

    func downloadImage(person: Person, tableView: UITableView, indexPath: IndexPath) {
        MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
            let indexSelf = tableView.indexPath(for: self)
            if ((indexSelf == nil) || (indexSelf == indexPath)) {
                if (error == nil) {
                    self.profileImageView.image = image
                    //self.labelInitials.text = nil
                } else {
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
        
        removeGestureRecognizer()
        cellGestureRecognizer()
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
    
    func removeGestureRecognizer() {
        _ = UITapGestureRecognizer(target: self, action: #selector(actionTapRemove))
    }
    
    func cellGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapCell))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(actionTapCell))
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(tapGesture1)
    }
    
    
    @objc func actionTapRemove() {
        if(cellType == 0){
            chatVCProtocol.removeFriend(indexPath)
        }else if cellType == 1{
            chatVCProtocol.groupInfo(group)
        }
    }
    
    @objc func actionTapCell() {
        if(cellType == 0){
            chatVCProtocol.singleChatView(indexPath)
        }else if cellType == 1{
            chatVCProtocol.groupChatView(indexPath)
        }
    }
    
    
    
}
