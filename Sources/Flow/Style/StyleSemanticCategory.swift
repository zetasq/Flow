//
//  StyleSemanticCategory.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/6.
//

import Foundation

public struct StyleSemanticCategory: RawRepresentable, Equatable {
  
  public let rawValue: String
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
}
