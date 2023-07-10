//
//  AutoLayoutBuilder.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/19.
//

import Foundation

@resultBuilder
public struct AutoLayoutBuilder {
  
  public static func buildBlock(_ stmts: AutoLayoutStmt...) -> AutoLayoutStmtGroup {
    return AutoLayoutStmtGroup(stmts: stmts)
  }
  
  public static func buildBlock(_ stmt: AutoLayoutStmt) -> AutoLayoutStmtGroup {
    return AutoLayoutStmtGroup(stmts: [stmt])
  }

}
