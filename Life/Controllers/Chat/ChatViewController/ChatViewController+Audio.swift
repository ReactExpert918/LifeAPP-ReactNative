//
//  ChatViewController+Audio.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import Foundation

extension ChatViewController: AudioDelegate {
    func didRecordAudio(path: String) {
        messageSend(text: nil, photo: nil, video: nil, audio: path)
    }
}
