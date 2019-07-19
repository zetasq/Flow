//
//  AutoLayoutAnchorAccessible.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/19.
//

import Foundation
import UIKit

public protocol AutoLayoutAnchorAccessible {
  
  var topAnchor: NSLayoutYAxisAnchor { get }
  
  var leftAnchor: NSLayoutXAxisAnchor { get }
  
  var bottomAnchor: NSLayoutYAxisAnchor { get }
  
  var rightAnchor: NSLayoutXAxisAnchor { get }
  
  var leadingAnchor: NSLayoutXAxisAnchor { get }
  
  var trailingAnchor: NSLayoutXAxisAnchor { get }
  
  var widthAnchor: NSLayoutDimension { get }
  
  var heightAnchor: NSLayoutDimension { get }
  
  var centerXAnchor: NSLayoutXAxisAnchor { get }
  
  var centerYAnchor: NSLayoutYAxisAnchor { get }
  
  var lastBaselineAnchor: NSLayoutYAxisAnchor { get }
  
  var firstBaselineAnchor: NSLayoutYAxisAnchor { get }
  
}

extension UIView: AutoLayoutAnchorAccessible {}

extension UILayoutGuide: AutoLayoutAnchorAccessible {
  
  public var lastBaselineAnchor: NSLayoutYAxisAnchor {
    fatalError("lastBaselineAnchor is not supported in \(type(of: self))")
  }
  
  public var firstBaselineAnchor: NSLayoutYAxisAnchor {
    fatalError("firstBaselineAnchor is not supported in \(type(of: self))")
  }
  
}
