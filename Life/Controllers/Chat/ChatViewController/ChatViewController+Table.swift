//
//  ChatViewController+Table.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit

extension ChatViewController {
    func configureTableView() {
        MoneyTableViewCell.Register(withTableView: self.tableView)
        tableView.register(RCHeaderUpperCell.self, forCellReuseIdentifier: "RCHeaderUpperCell")
        tableView.register(RCMessageTypingCell.self, forCellReuseIdentifier: "RCMessageTypingCell")
        tableView.register(RCHeaderLowerCell.self, forCellReuseIdentifier: "RCHeaderLowerCell")
        tableView.register(RCMessageEmojiCell.self, forCellReuseIdentifier: "RCMessageEmojiCell")
        tableView.register(MessagePhotoCell.self, forCellReuseIdentifier: "MessagePhotoCell")
        tableView.register(MessageCallCell.self, forCellReuseIdentifier: "MessageCallCell")
        tableView.register(RCMessageLocationCell.self, forCellReuseIdentifier: "RCMessageLocationCell")
        tableView.register(RCFooterUpperCell.self, forCellReuseIdentifier: "RCFooterUpperCell")
        tableView.register(RCFooterLowerCell.self, forCellReuseIdentifier: "RCFooterLowerCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
    }

    func refreshTableView() {
        print("refresh table view")
        tableView.reloadData()
    }

    func scrollToBottom() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom(animated: false)
        }
        detail?.update(lastRead: Date().timestamp())
    }

    func scrollToBottom(animated: Bool) {
        if (tableView.numberOfSections > 0) {
            let indexPath = IndexPath(row: 0, section: tableView.numberOfSections - 1)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }

    func indexPathBy(_ rcmessage: RCMessage) -> IndexPath? {
        for (index, dbmessage) in rcmessages.enumerated() {
            if (dbmessage.value.messageId == rcmessage.messageId) {
                let offset = messageTotalCount() - messageLoadedCount()
                return IndexPath(row: 2, section: index - offset)
            }
        }
        return nil
    }

    func actionTapAvatar(_ indexPath: IndexPath) {
        let rcmessage = rcmessageAt(indexPath)
        if(rcmessage.userId == AuthUser.userId()){
            return
        }
        guard let person = Persons.getById(rcmessage.userId) else {
            return
        }

        self.popupUserName.text = person.getFullName()
        self.popupPhoneNumber.text = person.phone
        self.popupCheckmark.isHidden = true
        if let path = MediaDownload.pathUser(person.objectId) {
            self.popupUserAvatar.image = UIImage.image(path, size: 40)
            self.popupCheckmark.isHidden = false
        } else {
            self.popupUserAvatar.image = nil
            //labelInitials.text = person.initials()
            MediaDownload.startUser(person.objectId, pictureAt: person.pictureAt) { image, error in
                if (error == nil) {
                    self.popupUserAvatar.image = image
                    self.popupUserAvatar.makeRounded()
                }
                else{
                    self.popupUserAvatar.image = UIImage(named: "ic_default_profile")
                }
                self.popupCheckmark.isHidden = false
            }
        }
        self.popupUserAvatar.makeRounded()
        self.popupView.isHidden = false
    }

    func layoutTableView() {
        print("SnapShot", heightKeyboard)
        let heightInput = messageInputBar.bounds.height - self.view.safeAreaInsets.bottom

        let edgeInset = UIEdgeInsets(top: 10, left: 0, bottom: heightInput + heightKeyboard + 10, right: 0)
        tableView.contentInset = edgeInset
        tableView.scrollIndicatorInsets = edgeInset
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return messageLoadedCount() + (self.isTyping ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let rcmessage = rcmessageAt(indexPath)
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_TEXT)     { return cellForMessageText(tableView, at: indexPath) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_EMOJI)    { return cellForMessageEmoji(tableView, at: indexPath) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO)    { return cellForMessagePhoto(tableView, at: indexPath) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO
                && indexPath == playingIndex)                    { return cellForMessageVideo(tableView, at: indexPath, isPlaying: true) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO)    { return cellForMessageVideo(tableView, at: indexPath) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO)    { return cellForMessageAudio(tableView, at: indexPath) }
            if (rcmessage.type == MESSAGE_TYPE.MISSED_CALL
                || rcmessage.type == MESSAGE_TYPE.CANCELLED_CALL
                || rcmessage.type == MESSAGE_TYPE.OUTGOING_CALL) { return cellForMessageCall(tableView, at: indexPath) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_LOCATION) { return cellForMessageLocation(tableView, at: indexPath) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_MONEY)    { return cellForMessageMoney(tableView, at: indexPath) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_ISTYPING) { return cellForTyping(tableView, at: indexPath) }
        }
        return UITableViewCell()
    }

    func cellForHeaderUpper(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RCHeaderUpperCell", for: indexPath) as! RCHeaderUpperCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    func cellForTyping(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageTypingCell", for: indexPath) as! RCMessageTypingCell
        cell.bindData(self, at: indexPath)
        return cell
    }
    func cellForHeaderLower(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RCHeaderLowerCell", for: indexPath) as! RCHeaderLowerCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    func cellForMessageText(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTextCell", for: indexPath) as! MessageTextCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    func cellForMessageEmoji(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageEmojiCell", for: indexPath) as! RCMessageEmojiCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    func cellForMessagePhoto(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagePhotoCell", for: indexPath) as! MessagePhotoCell
        cell.bindData(self, at: indexPath)
        return cell
    }


    func cellForMessageMoney(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoneyTableViewCell.GetCellReuseIdentifier(), for: indexPath) as! MoneyTableViewCell
        cell.bindData(messageAt(indexPath), messageView: self, indexPath: indexPath)
        return cell
    }

    func goPayDetail(_ zedPay: ZEDPay){
        let mainstoryboard = UIStoryboard.init(name: "ZedPay", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "detailVC") as! TransactionDetailViewController
        vc.transaction = zedPay
        self.present(vc, animated: true, completion: nil)
    }

    func cellForMessageVideo(_ tableView: UITableView, at indexPath: IndexPath, isPlaying: Bool = false) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageVideoCell", for: indexPath) as! MessageVideoCell
        cell.bindData(self, at: indexPath, isPlaying: isPlaying)
        return cell
    }

    func cellForMessageAudio(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageAudioCell", for: indexPath) as! MessageAudioCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    func cellForMessageCall(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCallCell", for: indexPath) as! MessageCallCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    func cellForMessageLocation(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageLocationCell", for: indexPath) as! RCMessageLocationCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    func cellForFooterUpper(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RCFooterUpperCell", for: indexPath) as! RCFooterUpperCell
        cell.bindData(self, at: indexPath)
        return cell
    }

    func cellForFooterLower(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RCFooterLowerCell", for: indexPath) as! RCFooterLowerCell
        cell.bindData(self, at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        view.isHidden = true
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        view.isHidden = true
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            let rcmessage = rcmessageAt(indexPath)

            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_TEXT)     { return UITableView.automaticDimension }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_EMOJI)    { return RCMessageEmojiCell.height(self, at: indexPath) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO)    { return MessagePhotoCell.height(self, at: indexPath) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO
                && indexPath == playingIndex)                    { return tableView.frame.width }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO)    { return 160 }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO)    { return 54 }
            if (rcmessage.type == MESSAGE_TYPE.MISSED_CALL
                || rcmessage.type == MESSAGE_TYPE.CANCELLED_CALL
                || rcmessage.type == MESSAGE_TYPE.OUTGOING_CALL) { return 60 }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_LOCATION) { return RCMessageLocationCell.height(self, at: indexPath) }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_MONEY)    { return 143 }
            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_ISTYPING) { return 46 }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        let offset = messageTotalCount() - messageLoadedCount()
//        let message = messages[section + offset]
//        var prevUserId = ""
//        if(section > 0){
//            prevUserId = messages[section + offset - 1].userId
//        }
//        var offsetHeight = CGFloat(3)
//        if (prevUserId != message.userId){
//            offsetHeight = RCDefaults.sectionHeaderMargin
//            prevUserId = message.userId
//        }
//        return offsetHeight
        return RCDefaults.sectionFooterMargin
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return RCDefaults.sectionFooterMargin
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.reloadInputViews()
    }
}
