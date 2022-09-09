//
//  VoiceRecordModel.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import JamitFoundation
import Combine

protocol VoiceRecordProtocol {
    func stop()
    func getAudioLevel() -> Float
}

struct VoiceRecordModel: ViewModelProtocol { }

extension VoiceRecordModel {
    static var `default`: VoiceRecordModel = .init()
}
