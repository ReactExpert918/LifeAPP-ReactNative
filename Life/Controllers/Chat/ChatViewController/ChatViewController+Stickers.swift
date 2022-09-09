//
//  ChatViewController+Stickers.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit

extension ChatViewController: StickersDelegate {
    func didSelectSticker(sticker: UIImage) {
        messageSend(text: nil, photo: sticker, video: nil, audio: nil)
    }
}
