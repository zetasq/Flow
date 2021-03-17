//
//  UIResponder+Utils.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/19.
//

import Foundation

extension PlatformAgnosticResponder {
  
  public final func searchResponderChain<T>(ofType type: T.Type) -> T? {
    var searchingResponder: PlatformAgnosticResponder? = self
    
    while let currentResponder = searchingResponder {
      if let castedObject = currentResponder as? T {
        return castedObject
      }
      
      searchingResponder = searchingResponder?.nextPlatformAgnosticResponder
    }
    
    return nil
  }
  
  public final func responderChain() -> [PlatformAgnosticResponder] {
    var chain: [PlatformAgnosticResponder] = []
    
    var traveller: PlatformAgnosticResponder? = self
    
    while let responder = traveller {
      chain.append(responder)
      traveller = traveller?.nextPlatformAgnosticResponder
    }
    
    return chain
  }
  
}
