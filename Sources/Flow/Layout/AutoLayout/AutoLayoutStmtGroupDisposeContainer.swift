//
//  AutoLayoutStmtGroupDisposeContainer.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/21.
//

import Foundation
import UIKit

public protocol AutoLayoutStmtGroupDisposeContainer: AnyObject {
  
  func injectNewGroup(_ group: AutoLayoutStmtGroup)
  
}

extension UIView: AutoLayoutStmtGroupDisposeContainer {
  
  private static var associatedGroupKey = "associatedGroupKey"
  
  private var associatedGroup: AutoLayoutStmtGroup? {
    get {
      if let existingGroup = objc_getAssociatedObject(self, &UIView.associatedGroupKey) as? AutoLayoutStmtGroup {
        return existingGroup
      } else {
        return nil
      }
    }
    
    set {
      objc_setAssociatedObject(self, &UIView.associatedGroupKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  public func injectNewGroup(_ group: AutoLayoutStmtGroup) {
    self.associatedGroup?.deactivate()
    self.associatedGroup = group
  }
  
}
