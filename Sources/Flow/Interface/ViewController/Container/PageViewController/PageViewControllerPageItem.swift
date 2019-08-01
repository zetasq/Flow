//
//  PageViewControllerPageItem.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/30.
//

import Foundation
import UIKit

public struct PageViewControllerPageItem<MetaData, ViewController: UIViewController> {
  
  public let metaData: MetaData
  
  public let viewControllerGenerator: () -> ViewController
  
  @inlinable
  public init(metaData: MetaData, viewControllerGenerator: @escaping () -> ViewController) {
    self.metaData = metaData
    self.viewControllerGenerator = viewControllerGenerator
  }
  
}
