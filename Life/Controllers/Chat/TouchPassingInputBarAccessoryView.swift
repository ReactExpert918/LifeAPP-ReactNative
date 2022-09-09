//
//  TouchPassingInputBarAccessoryView.swift
//  Life
//
//  Created by Farbod Rahiminik on 9/9/22.
//  Copyright © 2022 Zed. All rights reserved.
//

import UIKit
import InputBarAccessoryView

class TouchPassingInputBarAccessoryView: InputBarAccessoryView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden
                && subview.isUserInteractionEnabled
                && subview.point(inside: convert(point, to: subview), with: event)
                && subview.tag != VoiceRecord.Constant.trashTag {
                return true
            }
        }
        return false
    }
}
