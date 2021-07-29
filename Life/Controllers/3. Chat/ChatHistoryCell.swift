//
//  ChatHistoryCell.swift
//  Life
//
//  Created by Jaelhorton on 7/2/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import SwiftyAvatar

class ChatHistoryCell: UITableViewCell {

    @IBOutlet weak var profileImageView: SwiftyAvatar!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var lastUpdatedTimeLabel: UILabel!
    @IBOutlet weak var viewUnread: UIView!
    @IBOutlet weak var labelUnread: UILabel!
    
    
    func bindData(chat: Chat) {

        if chat.isPrivate  {
            let isRecipient = (chat.userId1 != AuthUser.userId())
            userNameLabel.text = isRecipient ? chat.fullName1 : chat.fullName2
        }
        else{
            userNameLabel.text = chat.details

        }
        lastMessageLabel.text = chat.typing ? "Typing..." : chat.lastMessageText

        lastUpdatedTimeLabel.text = Convert.timestampToCustom(chat.lastMessageAt)

        //imageMuted.isHidden = (chat.mutedUntil < Date().timestamp())
        viewUnread.isHidden = (chat.unreadCount == 0)

        labelUnread.text = (chat.unreadCount < 100) ? "\(chat.unreadCount)" : "..."
    }

    
    func loadImage(chat: Chat, tableView: UITableView, indexPath: IndexPath) {

        if (chat.isPrivate) {
            let isRecipient = (chat.userId1 != AuthUser.userId())
            let _ = isRecipient ? chat.userId1 : chat.userId2 // userId
            /*
            if let path = MediaDownload.pathUser(userId) {
                profileImageView.image = UIImage.image(path, size: 50)
                //labelInitials.text = nil
            } else {
                profileImageView.image = nil
                //labelInitials.text = chat.initials
                downloadImage(chat: chat, tableView: tableView, indexPath: indexPath)
            }
 */
            downloadImage(chat: chat, tableView: tableView, indexPath: indexPath)
        }

        if (chat.isGroup) {
            profileImageView.image = nil
            //labelInitials.text = chat.initials
        }
        
    }

    
    func downloadImage(chat: Chat, tableView: UITableView, indexPath: IndexPath) {
        let isRecipient = (chat.userId1 != AuthUser.userId())
        let userId = isRecipient ? chat.userId1 : chat.userId2
        let pictureAt = isRecipient ? chat.pictureAt1 : chat.pictureAt2
        
        MediaDownload.startUser(userId, pictureAt: pictureAt) { image, error in
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
        return "chatHistoryCell"
    }
    
    class func Register(withTableView tableView:UITableView) {
        tableView.register(self.GetCellNib(), forCellReuseIdentifier: self.GetCellReuseIdentifier())
    }
    
    class func GetCellNib() -> UINib {
        let aNib = UINib.init(nibName: "ChatHistoryCell",bundle: Bundle.main);
        return aNib
    }
}
