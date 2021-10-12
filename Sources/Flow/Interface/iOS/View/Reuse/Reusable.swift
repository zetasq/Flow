//
//  Reusable.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 17/03/2017.
//  Copyright © 2017 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

public protocol Reusable: UIView {
  
  static var reuseIdentifier: String { get }
  
}

public extension Reusable {
  
  static var reuseIdentifier: String {
    let qualifiedName = String(reflecting: self)
    return "\(qualifiedName).reuseIdentifier"
  }
  
}

#endif
