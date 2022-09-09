//
//  ChatViewController+Keyboard.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit

extension ChatViewController {

    // MARK: - Keyboard methods
    @objc func keyboardWillShow(_ notification: Notification) {
        popupView.isHidden = true
        showCallToolbar(value: false)
        guard heightKeyboard == 0 else { return }

        keyboardWillShow = true

        if let info = notification.userInfo {
            if let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                if let keyboard = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration)  {
                        if (self.keyboardWillShow) {
                            self.heightKeyboard = keyboard.size.height
                            self.layoutTableView()
                            self.scrollToBottom()
                        }
                    }
                }
            }
        }
        UIMenuController.shared.menuItems = nil
    }

    @objc func keyboardWillHide(_ notification: Notification?) {
        heightKeyboard = 0
        keyboardWillShow = false
        layoutTableView()
    }

    func dismissKeyboard() {
        if(keyboardWillShow){
            messageInputBar.inputTextView.resignFirstResponder()
        }
    }
}
