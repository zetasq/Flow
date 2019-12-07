//
//  UIKit+StyleAutomation.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/7.
//

import Foundation
import UIKit
import FlowObjC

extension UIView: Stylable {
  
  public var needsApplyStyleRulesRecursivelyImmediatelyForRulesChange: Bool {
    return self.window != nil
  }
  
  public var parentStylable: Stylable? {
    return superview
  }
  
  public var childStylables: [Stylable] {
    return subviews
  }

}

public let UIKitStyleAutomationOnceToken: Void = {
  UIView.flow_addViewDidMoveToWindowHandler { view in
    view.applyStyleRules()
  }
}()
