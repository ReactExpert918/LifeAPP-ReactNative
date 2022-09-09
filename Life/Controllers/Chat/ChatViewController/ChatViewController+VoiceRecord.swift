//
//  ChatViewController+VoiceRecord.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import Foundation

extension ChatViewController: VoiceRecordProtocol{

    func stop() {
        stopVoiceRecord()
        recordingView.cancelLockMode()
    }

    func getAudioLevel() -> Float {
        guard let recorder = recordingView.audioRecorder else { return 0 }
        recorder.updateMeters()
        let limitedToOne = min(1.0, recorder.peakPower(forChannel: 0) / recorder.averagePower(forChannel: 0))
        let limitedToZero = max(limitedToOne, 0.0)
        return limitedToZero
    }
}
