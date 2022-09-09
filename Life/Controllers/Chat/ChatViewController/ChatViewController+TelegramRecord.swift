//
//  ChatViewController+TelegramRecord.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit

extension ChatViewController: TelegramRecordViewDelegate {
    func didFinishRecording(url: URL) {
        DispatchQueue.main.async {
            self.telegramVideoView?.removeFromSuperview()
            self.telegramVideoView = nil
            self.messageSend(text: nil, photo: nil, video: url, audio: nil)

            for each in self.view.subviews {
                if each.tag == 42 {
                    each.removeFromSuperview()
                }
            }
        }
    }
}
