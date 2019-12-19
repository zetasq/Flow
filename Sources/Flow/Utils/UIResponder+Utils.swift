//
//  UIResponder+Utils.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/19.
//

import Foundation
import UIKit

extension UIResponder {
  
  public func searchResponderChain<T>(ofType type: T.Type) -> T? {
    var searchingResponder: UIResponder? = self
    
    while let currentResponder = searchingResponder {
      if let castedObject = currentResponder as? T {
        return castedObject
      }
      
      searchingResponder = searchingResponder?.next
    }
    
    return nil
  }
  
}
