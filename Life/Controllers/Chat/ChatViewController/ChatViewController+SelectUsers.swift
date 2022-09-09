//
//  ChatViewController+SelectUsers.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import Foundation

extension ChatViewController: SelectUsersDelegate {

    func didSelectUsers(userIds: [String]) {
        if let indexPath = indexForward {
            let message = messageAt(indexPath)
            for userId in userIds {
                let chatId = Singles.create(userId)
                Messages.forward(chatId: chatId, message: message)
            }
            indexForward = nil
        }
    }
}
