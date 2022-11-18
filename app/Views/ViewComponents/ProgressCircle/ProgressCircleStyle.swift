//
//  ProgressCircleStyle.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/07/14.
//

import Foundation
import UIKit
import GradientCircularProgress

public struct ProgressCircleStyle : StyleProperty {
    // Progress Size
   public var progressSize: CGFloat = 180
   
   // Gradient Circular
   public var arcLineWidth: CGFloat  = 4.0
   public var startArcColor: UIColor = ColorUtil.toUIColor(r: 255.0, g: 119.0, b: 3.0, a: 1.0)
   public var endArcColor: UIColor   = ColorUtil.toUIColor(r: 228.0, g: 73.0, b: 28.0, a: 1.0)
   
   // Base Circular
   public var baseLineWidth: CGFloat? = 5.0
   public var baseArcColor: UIColor? = UIColor(red:0.0, green: 0.0, blue: 0.0, alpha: 0.2)
   
   // Ratio
   public var ratioLabelFont: UIFont? = UIFont(name: "Verdana-Bold", size: 30.0)
   public var ratioLabelFontColor: UIColor? = UIColor.white
   
   // Message
   public var messageLabelFont: UIFont? = UIFont.systemFont(ofSize: 20.0)
   public var messageLabelFontColor: UIColor? = UIColor.white
   
   // Background
    public var backgroundStyle: BackgroundStyles = .dark
   
   // Dismiss
   public var dismissTimeInterval: Double? = nil // 'nil' for default setting.
    
    public init(){}
}
