//
//  AutoLayout.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/19.
//

import UIKit

@discardableResult
public func AutoLayout(autoActivate: Bool = true, @AutoLayoutBuilder builder: () -> AutoLayoutStmtGroup) -> AutoLayoutStmtGroup {
  let group = builder()
  
  if autoActivate {
    group.activate()
  }
  
  return group
}

