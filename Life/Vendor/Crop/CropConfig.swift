//
//  CropConfig.swift
//  Readminder
//
//  Created by Steve on 4/5/20.
//  Copyright © 2020 Steve. All rights reserved.
//

import UIKit

public typealias Transformation = (
    offset: CGPoint,
    rotation: CGFloat,
    scale: CGFloat,
    manualZoomed: Bool
)

public typealias CropInfo = (translation: CGPoint, rotation: CGFloat, scale: CGFloat, cropSize: CGSize, imageViewSize: CGSize)

public enum PresetTransformationType {
    case none
    case presetInfo(info: Transformation)
}

public enum PresetFixedRatioType {
    /** When choose alwaysUsingOnePresetFixedRatio, fixed-ratio setting button does not show.
     */
    case alwaysUsingOnePresetFixedRatio(ratio: Double)
    case canUseMultiplePresetFixedRatio
}

public enum CropShapeType {
    case rect
    case ellipse
    case roundedRect(radiusToShortSide: CGFloat)
}

public struct CropConfig {
    public var presetTransformationType: PresetTransformationType = .none
    public var cropShapeType: CropShapeType = .rect
    public var ratioOptions: RatioOptions = .all
    public var presetFixedRatioType: PresetFixedRatioType = .canUseMultiplePresetFixedRatio
    public var showRotationDial = true
    public var showRatioButton = true
    public var optionButtonFontSize: CGFloat = 14
    public var optionButtonFontSizeForPad: CGFloat = 20
    
    public var toolBarBackgroundColor: UIColor = .black
    
    var customRatios: [(width: Int, height: Int)] = []
    
    public init() {
    }
        
    mutating public func addCustomRatio(byHorizontalWidth width: Int, andHorizontalHeight height: Int) {
        customRatios.append((width, height))
    }

    mutating public func addCustomRatio(byVerticalWidth width: Int, andVerticalHeight height: Int) {
        customRatios.append((height, width))
    }
    
    func hasCustomRatios() -> Bool {
        return customRatios.count > 0
    }
    
    func getCustomRatioItems() -> [RatioItemType] {
        return customRatios.map {
            (String("\($0.width):\($0.height)"), Double($0.width)/Double($0.height), String("\($0.height):\($0.width)"), Double($0.height)/Double($0.width))
        }
    }
}
