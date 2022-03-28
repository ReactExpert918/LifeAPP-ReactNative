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
}

class SKRecordView: UIView, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    enum SKRecordViewState {
        case recording
        case none
    }
    var state : SKRecordViewState = .none {
        didSet {
            if state != .recording{
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    
                    self.slideToCancel.alpha = 1.0
                    self.countDownLabel.alpha = 1.0
                    
                    self.invalidateIntrinsicContentSize()
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                    
                }) 
                
            }else{
                self.slideToCancel.alpha = 1.0
                self.countDownLabel.alpha = 1.0
                
                self.invalidateIntrinsicContentSize()
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
    var viewcontroller: UIViewController!
    var recordButton : InputBarButtonItem = InputBarButtonItem()
    let slideToCancel : UILabel = UILabel(frame: CGRect.zero)
    let countDownLabel : UILabel = UILabel(frame: CGRect.zero)
    var timer:Timer!
    var recordSeconds = 0
    var recordMinutes = 0
    var audioRecorder: AVAudioRecorder?
    
    var normalImage = UIImage(named: "ic_record.png")!
    var recordingImages = [UIImage(named: "rec-1.png")!,UIImage(named: "rec-2.png")!,UIImage(named: "rec-3.png")!,UIImage(named: "rec-4.png")!,UIImage(named: "rec-5.png")!,UIImage(named: "rec-6.png")!]
    var recordingAnimationDuration = 0.5
    var recordingLabelText = "<< Slide to cancel"
    
    var delegate : SKRecordViewDelegate?
    var fileName = Date().timeIntervalSince1970
    
    init(recordBtn: InputBarButtonItem, vc: UIViewController) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewcontroller = vc
        setupRecordButton(normalImage, recordBtn: recordBtn)
        setupLabel()
        setupCountDownLabel()
    }
    
    func setupRecordButton(_ image:UIImage, recordBtn: InputBarButtonItem) {
        recordButton = recordBtn
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        recordButton.setImage(image, for: UIControl.State())
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SKRecordView.actionLongPress(_:)))
        longPress.cancelsTouchesInView = false
        longPress.allowableMovement = 10
        longPress.minimumPressDuration = 0.3
        recordButton.addGestureRecognizer(longPress)
        
        recordButton.imageView?.animationImages = recordingImages
        recordButton.imageView?.animationDuration = recordingAnimationDuration
    }
    
    func setupLabel() {
        slideToCancel.translatesAutoresizingMaskIntoConstraints = false
        slideToCancel.textAlignment = .center
        slideToCancel.font = UIFont.init(name: "system", size: 9.0)
        addSubview(slideToCancel)
        
        NSLayoutConstraint.activate([
            slideToCancel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            slideToCancel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -70)
        ])
        
        slideToCancel.font = UIFont.boldSystemFont(ofSize: 14)
        slideToCancel.textAlignment = .center
        slideToCancel.textColor = UIColor.black
        slideToCancel.text = recordingLabelText
    }
    
    
    func setupCountDownLabel() {
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        countDownLabel.textAlignment = .center
        addSubview(countDownLabel)
        
        NSLayoutConstraint.activate([
            countDownLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            countDownLabel.trailingAnchor.constraint(equalTo: self.slideToCancel.leadingAnchor, constant: -8)
        ])
        
        countDownLabel.font = UIFont.systemFont(ofSize: 15)
        countDownLabel.textAlignment = .center
        countDownLabel.textColor = UIColor.red
        countDownLabel.text = "0.00"
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
            
            return CGSize(width: recordButton.intrinsicContentSize.width * 3, height: recordButton.intrinsicContentSize.height)
        }
    }
    
    func ClearView() {
        slideToCancel.text = nil
        countDownLabel.text = nil
        timer.invalidate()
    }
    
    func recordAudio() {
        self.fileName = Date().timeIntervalSince1970
        self.setupRecorder()
        
        let settings = [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1]
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: self.getFileURL(), settings: settings)
            self.audioRecorder?.delegate = self
            
            audioRecorder?.record()
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
        self.ClearView()
        self.finishRecording()
        
        delegate?.SKRecordViewDidCancelRecord(self, button: sender)
    }
    
    func userDidStopRecording(_ sender: UIButton) {
        self.ClearView()
        self.finishRecording()
        
        delegate?.SKRecordViewDidStopRecord(self, button: sender)
    }
    
    func userDidBeginRecord(_ sender : UIButton) {
        slideToCancel.text = self.recordingLabelText
        recordMinutes = 0
        recordSeconds = 0
        countdown()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SKRecordView.countdown) , userInfo: nil, repeats: true)
        
        
        self.recordAudio()
        delegate?.SKRecordViewDidSelectRecord(self, button: sender)
    }
    
    @objc func countdown() {
        var seconds = "\(recordSeconds)"
        if recordSeconds < 10 {
            seconds = "0\(recordSeconds)"
        }
        var minutes = "\(recordMinutes)"
        if recordMinutes < 10 {
            minutes = "0\(recordMinutes)"
        }
        
        countDownLabel.text = "● \(minutes):\(seconds)"
        recordSeconds += 1
        if recordSeconds == 60 {
            recordMinutes += 1
            recordSeconds = 0
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
        case .changed:
            let translate = CGPoint(x: location.x - startLocation.x, y: location.y - startLocation.y)
            if !button.bounds.contains(translate) {
                if state == .recording {
                    userDidTapRecordThenSwipe(button)
                }
            }
        case .ended:
            if state == .none { return }
//            let translate = CGPoint(x: location.x - startLocation.x, y: location.y - startLocation.y)
//            print("Tested:", translate, button.frame)
//            if !button.frame.contains(translate) {
//                userDidStopRecording(button)
//            }
            
            if state == .recording {
                userDidStopRecording(button)
            }
            
        case .failed, .possible ,.cancelled : if state == .recording { userDidStopRecording(button) } else { userDidTapRecordThenSwipe(button)}
        @unknown default:
            if state == .recording { userDidStopRecording(button) } else { userDidTapRecordThenSwipe(button)}
        }
    }
    
    @objc func actionCancel() {
        
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Recorder", error)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Audio Recorder", flag)
        self.ClearView()
        self.finishRecording()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

