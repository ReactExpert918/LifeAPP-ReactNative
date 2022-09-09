//
//  ChatViewController+PhotoSelection.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit

extension ChatViewController: PhotoSelectionViewDelegate {
    func didSelectPhoto(image: UIImage?) {
        messageSend(text: nil, photo: image, video: nil, audio: nil)
    }
}
