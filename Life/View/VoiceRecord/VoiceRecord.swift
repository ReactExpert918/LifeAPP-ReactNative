//
//  VoiceRecord.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import JamitFoundation

class VoiceRecord: StatefulView<VoiceRecordModel>{
    
    @IBOutlet var lockTrackView: UIView!
    @IBOutlet var lockControlView: UIStackView!
    @IBOutlet weak var lockDurationLabel: UILabel!
    @IBOutlet var defaultControlView: UIStackView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var micImageView: UIImageView!
    @IBOutlet weak var slideLabel: UILabel!
    @IBOutlet weak var lockContainerView: UIView!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var audioGraph: UIView!
    
    var timer: Timer? = nil
    var time = 0

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        }
        return hitView
    }

    @IBAction func lockTrashDidTap(_ sender: Any) {
        
    }

    @objc
    func fireTimer() {
        time += 1

        let hours = Int(self.time) / 3600
        let minutes = Int(self.time) / 60 % 60
        let seconds = Int(self.time) % 60
        let duration = String(format:"%02i:%02i:%02i", hours, minutes, seconds)

        lockDurationLabel.text = duration
        durationLabel.text = duration
    }

    private func deinitTimer() {
        guard timer == nil else { return }
        timer?.invalidate()
        timer = nil
    }

    func defaultConfiguration() {
        lockTrackView.isHidden = true
        lockControlView.isHidden = true

        lockContainerView.isHidden = true

        defaultControlView.isHidden = true

        mainContainerView.isHidden = true
        backgroundView.isHidden = true

        deinitTimer()
    }

    func recordConfiguration() {
        lockTrackView.isHidden = true
        lockControlView.isHidden = true

        lockContainerView.isHidden = false

        defaultControlView.isHidden = false

        mainContainerView.isHidden = false
        backgroundView.isHidden = true

        time = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                                 target: self,
                                                 selector: #selector(fireTimer),
                                                 userInfo: nil,
                                                 repeats: true)

        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            options: [.transitionFlipFromLeft, .repeat, .autoreverse],
            animations: {
                self.micImageView.alpha = 0
                self.slideLabel.alpha = 0
            })
    }

    func lockConfiguration() {
        lockTrackView.isHidden = false
        lockControlView.isHidden = false

        lockContainerView.isHidden = true

        defaultControlView.isHidden = true

        mainContainerView.isHidden = false

        backgroundView.isHidden = false
    }
}
