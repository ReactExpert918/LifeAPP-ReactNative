//
//  ChatViewController+Menu.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit

extension ChatViewController {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (action == #selector(actionMenuCopy(_:)))    { return true }
        if (action == #selector(actionMenuSave(_:)))    { return true }
        if (action == #selector(actionMenuDelete(_:)))  { return true }
        return false
    }

    @objc func actionMenuCopy(_ sender: Any?) {
        if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
            let rcmessage = rcmessageAt(indexPath)
            UIPasteboard.general.string = rcmessage.text
        }
    }

    @objc func actionMenuSave(_ sender: Any?) {

        if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
            let rcmessage = rcmessageAt(indexPath)

            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO) {
                if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
                    if let image = rcmessage.photoImage {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }
            }

            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO) {
                if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
                    UISaveVideoAtPathToSavedPhotosAlbum(rcmessage.videoPath, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }

            if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO) {
                if (rcmessage.mediaStatus == MediaStatus.MEDIASTATUS_SUCCEED) {
                    let path = File.temp(ext: "mp4")
                    File.copy(src: rcmessage.audioPath, dest: path, overwrite: true)
                    UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }

    @objc func actionMenuDelete(_ sender: Any?) {
        if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
            let message = messageAt(indexPath)
            message.update(isDeleted: true)
        }
    }

    func menuItems(_ indexPath: IndexPath) -> [RCMenuItem]? {
        let menuItemCopy = RCMenuItem(title: "Copy".localized, action: #selector(actionMenuCopy(_:)))
        let menuItemSave = RCMenuItem(title: "Save".localized, action: #selector(actionMenuSave(_:)))
        let menuItemDelete = RCMenuItem(title: "Delete".localized, action: #selector(actionMenuDelete(_:)))

        menuItemCopy.indexPath = indexPath
        menuItemSave.indexPath = indexPath
        menuItemDelete.indexPath = indexPath
        let rcmessage = rcmessageAt(indexPath)
        var array: [RCMenuItem] = []

        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_TEXT)     { array.append(menuItemCopy) }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_EMOJI)    { array.append(menuItemCopy) }

        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_PHOTO)    { array.append(menuItemSave) }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_VIDEO)    { array.append(menuItemSave) }
        if (rcmessage.type == MESSAGE_TYPE.MESSAGE_AUDIO)    { array.append(menuItemSave) }

        array.append(menuItemDelete)
        return array
    }
}
