//
//  ChatViewController+InputBar.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import InputBarAccessoryView

extension ChatViewController {


    func actionSendMessage(_ text: String) {
        messageSend(text: text, photo: nil, video: nil, audio: nil)
    }
    func typingIndicatorUpdate() {
        typingCounter.invalidate()
        ref.child("Typing").child(self.chatId).child(AuthUser.userId()).setValue(true)
        typingCounter = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(typingIndicatorStop), userInfo: nil, repeats: false)
    }

    @objc func typingIndicatorStop() {
        self.ref.child("Typing").child(self.chatId).child(AuthUser.userId()).setValue(false)
        detail?.update(typing: false)
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if (text != "") {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            typingIndicatorUpdate()
        } else {
            messageInputBar.setStackViewItems([recordingView.recordButton], forStack: .right, animated: false)
        }
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) { }

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                self.messageInputBar.sendButton.startAnimating()
                actionSendMessage(text)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.messageInputBar.sendButton.stopAnimating()
                }
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}

extension ChatViewController: AutocompleteManagerDelegate, AutocompleteManagerDataSource {

    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        if prefix == "@" {

            var autoList:[AutocompleteCompletion] = []
            for user in users {
                autoList.append(AutocompleteCompletion(text: user.name))
            }
            return autoList
        } else {
            return ["InputBarAccessoryView", "iOS"].map { AutocompleteCompletion(text: $0) }
        }
    }

    func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else {
            fatalError("Oops, some unknown error occurred")
        }
        if session.prefix == "@" {
            let user = users[indexPath.row]
            cell.imageView?.image = user.image
            cell.imageViewEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            cell.imageView?.layer.cornerRadius = 8
            cell.imageView?.layer.borderWidth = 1
            cell.imageView?.layer.borderColor = UIColor.systemBlue.cgColor
            cell.imageView?.layer.masksToBounds = true
        }
        cell.textLabel?.attributedText = manager.attributedText(matching: session, fontSize: 15, keepPrefix: session.prefix == "#" )
        return cell
    }

    // MARK: - AutocompleteManagerDelegate

    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }

    // MARK: - AutocompleteManagerDelegate Helper

    func setAutocompleteManager(active: Bool) {
        let topStackView = self.messageInputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        self.messageInputBar.invalidateIntrinsicContentSize()
    }
}
