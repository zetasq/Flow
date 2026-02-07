//
//  ViewProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/7/2.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

@MainActor
public protocol ViewModelViewOverridenProtocol {
  
  func viewModelDidUpdate()
  
}

public protocol ViewModelViewProtocol: AnyObject, ViewModelViewOverridenProtocol {
  
  associatedtype ViewModel

}

extension ViewModelViewProtocol where Self: UIView {

  public var viewModel: ViewModel? {
    return self._associatedViewModel as? ViewModel
  }
  
}

#endif
