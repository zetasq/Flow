//
//  Stylable.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/4.
//

import Foundation

public protocol Stylable: AnyObject {
  
  var needsApplyStyleRulesRecursivelyImmediatelyForRulesChange: Bool { get }
  
  var parentStylable: Stylable? { get }
  
  var childStylables: [Stylable] { get }
  
}
