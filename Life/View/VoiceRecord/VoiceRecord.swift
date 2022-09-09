//
//  VoiceRecord.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import JamitFoundation
import SoundWave


class VoiceRecord: StatefulView<VoiceRecordModel>{

    enum Constant {
        static let trashTag = 1000
    }

    @IBOutlet var lockTrackView: UIView!
    @IBOutlet var lockControlView: UIStackView!
    @IBOutlet weak var lockDurationLabel: UILabel!
    @IBOutlet var defaultControlView: UIStackView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var micImageView: UIImageView!
    @IBOutlet weak var slideLabel: UILabel!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var audioView: AudioVisualizationView!
    @IBOutlet weak var trashButton: UIButton!

    var delegate: VoiceRecordProtocol? = nil
    private var timer: Timer? = nil
    var time: Double = 0

    override func viewDidLoad() {
        hideForDefaultConfiguration()
        configureAudioView()
        trashButton.tag = Constant.trashTag
    }

    func lockTrashDidTap() {
        delegate?.stop()
        hideForDefaultConfiguration()
    }

    func fireTimer() {
        time += 0.5

        let hours = Int(self.time) / 3600
        let minutes = Int(self.time) / 60 % 60
        let seconds = Int(self.time) % 60
        let duration = String(format:"%02i:%02i:%02i", hours, minutes, seconds)

        lockDurationLabel.text = duration
        durationLabel.text = duration

        guard let level = delegate?.getAudioLevel() else { return }
        audioView.add(meteringLevel: level)
    }
    private func deinitTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
        time = 0
    }

    func configureAudioView() {
        audioView.meteringLevelBarWidth = 1.0
        audioView.meteringLevelBarInterItem = 1.0
        audioView.meteringLevelBarCornerRadius = 0.5
        audioView.gradientStartColor = .red
        audioView.gradientEndColor = .red
        audioView.backgroundColor = .clear
        audioView.audioVisualizationMode = .write
    }

    func defaultConfiguration() {
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            options: [.transitionCurlDown],
            animations: {
                self.disappearForDefaultConfiguration()
            }, completion: { _ in
                self.hideForDefaultConfiguration()
            })

        deinitTimer()
        audioView.reset()
    }

    func hideForDefaultConfiguration() {
        lockTrackView.isHidden = true
        lockControlView.isHidden = true
        defaultControlView.isHidden = true
        mainContainerView.isHidden = true
    }
    func disappearForDefaultConfiguration() {
        lockTrackView.alpha = 0
        lockControlView.alpha = 0
        defaultControlView.alpha = 0
        mainContainerView.alpha = 0
    }

    func recordConfiguration() {
        showForRecordConfiguration()

        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            options: [.transitionCurlUp],
            animations: {
                self.appearForRecordConfiguration()
            })

        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            options: [.transitionCurlDown],
            animations: {
                self.disappearForRecordConfiguration()
            }, completion: { _ in
                self.hideForRecordConfiguration()
            })

        deinitTimer()
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5,
                                         repeats: true,
                                         block: { [weak self] _ in
                self?.fireTimer()
            })
        }

        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            options: [.transitionFlipFromLeft, .repeat, .autoreverse],
            animations: {
                self.micImageView.alpha = 0
                self.slideLabel.alpha = 0
            })
    }

    func hideForRecordConfiguration() {
        lockTrackView.isHidden = true
        lockControlView.isHidden = true
    }

    func showForRecordConfiguration() {
        defaultControlView.isHidden = false
        mainContainerView.isHidden = false
    }

    func disappearForRecordConfiguration() {
        lockTrackView.alpha = 0
        lockControlView.alpha = 0
    }

    func appearForRecordConfiguration() {
        defaultControlView.alpha = 1
        mainContainerView.alpha = 1
    }

    func lockConfiguration() {
        showForLockConfiguration()

        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            options: [.transitionCurlUp],
            animations: {
                self.appearForLockConfiguration()
            })

        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            options: [.transitionCurlDown],
            animations: {
                self.disappearForLockConfiguration()
            }, completion: { _ in
                self.hideForLockConfiguration()
            })
    }

    func hideForLockConfiguration() {
        defaultControlView.isHidden = true
    }

    func showForLockConfiguration() {
        lockTrackView.isHidden = false
        lockControlView.isHidden = false
        mainContainerView.isHidden = false
    }

    func disappearForLockConfiguration() {
        defaultControlView.alpha = 0
    }

    func appearForLockConfiguration() {
        lockTrackView.alpha = 1
        lockControlView.alpha = 1
        mainContainerView.alpha = 1
    }
}
