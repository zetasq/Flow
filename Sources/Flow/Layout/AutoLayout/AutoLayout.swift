//
//  AutoLayout.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/19.
//

@discardableResult
public func AutoLayout(autoActivate: Bool = true, boundDisposeContainer: AutoLayoutStmtGroupDisposeContainer? = nil, @AutoLayoutBuilder builder: () -> AutoLayoutStmtGroup) -> AutoLayoutStmtGroup {
  let group = builder()
  
  if let container = boundDisposeContainer {
    container.injectNewGroup(group)
  }
  
  if autoActivate {
    group.activate()
  }
  
  return group
}

