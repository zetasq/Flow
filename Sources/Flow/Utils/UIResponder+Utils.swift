//
//  UIResponder+Utils.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/19.
//

import Foundation
import UIKit

extension UIResponder {
  
  public final func searchResponderChain<T>(ofType type: T.Type) -> T? {
    var searchingResponder: UIResponder? = self
    
    while let currentResponder = searchingResponder {
      if let castedObject = currentResponder as? T {
        return castedObject
      }
      
      searchingResponder = searchingResponder?.next
    }
    
    return nil
  }
  
  public final func responderChain() -> [UIResponder] {
    var chain: [UIResponder] = []
    
    var traveller: UIResponder? = self
    
    while let responder = traveller {
      chain.append(responder)
      traveller = traveller?.next
    }
    
    return chain
  }
  
}
