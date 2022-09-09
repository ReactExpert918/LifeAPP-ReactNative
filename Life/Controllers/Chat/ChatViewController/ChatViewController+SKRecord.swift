//
//  ChatViewController+SKRecord.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit

extension ChatViewController : SKRecordViewDelegate {
    func userWantsToRecordVideo() {
        let colorview = UIView()
        colorview.tag = 42
        colorview.backgroundColor = .black.withAlphaComponent(0.4)
        colorview.frame = self.view.bounds
        view.addSubview(colorview)

        telegramVideoView = .instantiate()
        guard let telegramVideo = telegramVideoView else { return }
        view.addSubview(telegramVideo)

        telegramVideo.delegate = self
        telegramVideo.snp.makeConstraints { make in
            make.height.width.equalTo(200)
            make.centerX.centerY.equalToSuperview()
        }

        self.telegramVideoView?.startRecording()
    }

    func SKRecordViewDidCancelRecord(_ sender: SKRecordView, button: UIView) {
        sender.state = .none
        let image = sender.isVideo ? UIImage(named: "ic_video_clip")! : UIImage(named: "ic_record.png")!
        sender.setupRecordButton(image, recordBtn: hybridButton)
        //recordingView.audioRecorder?.stop()
        recordingView.recordButton.imageView?.stopAnimating()
        messageInputBar.inputTextView.placeholder = "Enter a message".localized
        //messageInputBar.isHidden = false
        recordingView.isHidden = true
        messageInputBar.inputTextView.isHidden = false
        messageInputBar.leftStackView.isHidden = false
        print("Cancelled")

        if !sender.isVideo {
            stopVoiceRecord()
        }
    }

    func SKRecordViewDidSelectRecord(_ sender: SKRecordView, button: UIView) {

        sender.state = .recording
        recordingView.recordButton.imageView?.startAnimating()
        recordingView.isHidden = false
        messageInputBar.inputTextView.placeholder = nil
        messageInputBar.inputTextView.isHidden = true
        messageInputBar.leftStackView.isHidden = true

        print("Began " + NSUUID().uuidString)

        if !sender.isVideo {
            startVoiceRecord()
        }
    }

    func SKRecordViewDidStopRecord(_ sender : SKRecordView, button: UIView) {
        //recordingView.audioRecorder?.stop()
        let image = sender.isVideo ? UIImage(named: "ic_video_clip")! : UIImage(named: "ic_record.png")!
        sender.setupRecordButton(image, recordBtn: hybridButton)
        recordingView.recordButton.imageView?.stopAnimating()
        sender.state = .none

        if sender.isVideo == false {
            messageSend(text: nil, photo: nil, video: nil, audio: recordingView.getFileURL().path)
            print("audio url==>",recordingView.getFileURL().path)
            messageInputBar.inputTextView.placeholder = "Enter a message".localized
            //messageInputBar.isHidden = false
        }

        if sender.isVideo {
            telegramVideoView?.stopRecording()
        }

        messageInputBar.inputTextView.isHidden = false
        messageInputBar.leftStackView.isHidden = false

        recordingView.isHidden = true
        tableView.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: true)

        if !sender.isVideo {
            stopVoiceRecord()
        }
    }
}
