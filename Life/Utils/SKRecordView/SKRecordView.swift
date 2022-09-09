//
//  SKRecordView.swift
//  SKRecordView
//
//  Created by sherif_khaled on 10/5/16.
//  Copyright © 2016 sherif khaled. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import InputBarAccessoryView
import MobileCoreServices

protocol SKRecordViewDelegate {
    func SKRecordViewDidSelectRecord(_ sender : SKRecordView, button: UIView)
    func SKRecordViewDidStopRecord(_ sender : SKRecordView, button: UIView)
    func SKRecordViewDidCancelRecord(_ sender : SKRecordView, button: UIView)
    func userWantsToRecordVideo()
}

class SKRecordView: UIView, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    enum SKRecordViewState {
        case recording
        case none
        case locked
        case swipe
    }
    var state : SKRecordViewState = .none {
        didSet {
            dismissLock()
            if state == .locked { setupLock() }
        }
    }
    
    var isVideo: Bool = false
    var viewcontroller: UIViewController!
    var chatViewController: ChatViewController? {
        viewcontroller as? ChatViewController
    }

    var recordButton : InputBarButtonItem = InputBarButtonItem()
    var audioRecorder: AVAudioRecorder?
    var normalImage = UIImage(named: "ic_record.png")!
    var delegate : SKRecordViewDelegate?
    var fileName = Date().timeIntervalSince1970
    var buttonOriginY: CGFloat = 0
    var buttonOriginX: CGFloat = 0

    init(recordBtn: InputBarButtonItem, vc: UIViewController) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewcontroller = vc
        setupRecordButton(normalImage, recordBtn: recordBtn)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            print("\(subview.tag)")
            if !subview.isHidden
                && subview.isUserInteractionEnabled
                && subview.point(inside: convert(point, to: subview), with: event)
                && subview.tag != VoiceRecord.Constant.trashTag {
                return true
            }
        }
        return false
    }

    func setupRecordButton(_ image: UIImage, recordBtn: InputBarButtonItem) {
        recordButton = recordBtn
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setImage(image, for: UIControl.State())
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SKRecordView.actionLongPress(_:)))
        longPress.cancelsTouchesInView = true
        longPress.allowableMovement = 10
        longPress.minimumPressDuration = 0.3

        recordButton.addGestureRecognizer(longPress)
        buttonOriginY = recordButton.frame.origin.y
        buttonOriginX = recordButton.frame.origin.x
    }

    func setupRecorder(){
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission { _ in
                
            }
        } catch (let error) {
            print("Audio Recorder", error)
        }
    }
    
    func getCacheDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        return paths[0]
    }
    
    func getFileURL() -> URL{
        
        let fileMgr = FileManager.default
        
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        let soundFileURL = dirPaths[0].appendingPathComponent("\(fileName)-sound.m4a")
        return soundFileURL
    }
    
    
    override var intrinsicContentSize : CGSize {
        if state == .none {
            return recordButton.intrinsicContentSize
        } else {
            return CGSize(width: recordButton.intrinsicContentSize.width * 3,
                          height: recordButton.intrinsicContentSize.height)
        }
    }

    func recordAudio() {
        self.fileName = Date().timeIntervalSince1970
        self.setupRecorder()
        
        let settings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1]
        
        do {
            audioRecorder = try AVAudioRecorder(url: self.getFileURL(), settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            audioRecorder?.isMeteringEnabled = true
        } catch (let error) {
            print("Audio Recorder", error)
            finishRecording()
        }
    }
    
    func finishRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    func userDidTapRecordThenSwipe(_ sender: UIButton) {
        self.finishRecording()
        
        delegate?.SKRecordViewDidCancelRecord(self, button: sender)
    }
    
    func  userDidStopRecording(_ sender: UIButton) {
        if !isVideo {
            self.finishRecording()
        }
        delegate?.SKRecordViewDidStopRecord(self, button: sender)
    }
    
    func userDidBeginRecord(_ sender : UIButton) {
        if !isVideo {
            self.recordAudio()
            delegate?.SKRecordViewDidSelectRecord(self, button: sender)
        } else {
            delegate?.userWantsToRecordVideo()
        }
    }

    func moveButtonIfLockRecordingAudio(distance: CGFloat) {
        if state == .locked && !isVideo {
            let zeroLimited = min(0, distance)
            let move = recordButton.frame.origin.y + zeroLimited
            let maxLimited = max(move, -200)
            recordButton.frame.origin.y = maxLimited
        }
    }
    func moveButtonIfSwipeRecordingAudio(distance: CGFloat) {
        if state == .swipe && !isVideo {
            let zeroLimited = min(0, distance)
            let move = recordButton.frame.origin.x + zeroLimited
            let maxLimited = max(move, -150)
            recordButton.frame.origin.x = maxLimited
        }
    }
    
    @objc func actionLongPress(_ gesture: UIGestureRecognizer) {
        let button = gesture.view as! UIButton
        let location = gesture.location(in: button)
        var startLocation = CGPoint.zero
        switch gesture.state {
        case .began:
            startLocation = location
            userDidBeginRecord(button)
            if !isVideo {
                chatViewController?.startVoiceRecord()
            }
        case .changed:
            let x = location.x - startLocation.x
            let y = location.y - startLocation.y
            let translate = CGPoint(x: x, y: y)

            moveButtonIfLockRecordingAudio(distance: y)
            moveButtonIfSwipeRecordingAudio(distance: x)

            if !button.bounds.contains(translate) {
                if state == .recording {
                    if y < button.bounds.minY && !isVideo {
                        state = .locked
                    } else if x < button.bounds.minX {
                        state = .swipe
                    }
                }
            }
        case .ended:
            if isVideo || state == .recording {
                userDidStopRecording(button)
            }
            if !isVideo {
                if state == .locked {
                    UIView.animate(withDuration: 0.7) {
                        self.recordButton.frame.origin.y = self.buttonOriginY
                    }
                    chatViewController?.lockVoiceRecord()
                } else if state == .swipe {
                    UIView.animate(withDuration: 0.7) {
                        self.recordButton.frame.origin.x = self.buttonOriginX
                    }
                    userDidTapRecordThenSwipe(button)
                }
            }

        case .failed, .possible ,.cancelled : if state == .recording { userDidStopRecording(button) } else { userDidTapRecordThenSwipe(button)}
        @unknown default:
            if state == .recording { userDidStopRecording(button) } else { userDidTapRecordThenSwipe(button)}
        }
    }
    
    @objc func actionCancel() {
        
    }
    func finishLockMode(){
        guard state == .locked else { return }
        state = .none
        userDidStopRecording(recordButton)
    }

    func cancelLockMode(){
        guard state == .locked else { return }
        state = .none
        userDidTapRecordThenSwipe(recordButton)
    }

    func setupLock() {
        recordButton.backgroundColor = COLORS.PRIMARY
        recordButton.layer.cornerRadius = min(recordButton.frame.height, recordButton.frame.width) / 2
    }

    func dismissLock() {
        recordButton.backgroundColor = .clear
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Recorder", error)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Audio Recorder", flag)
        self.finishRecording()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
