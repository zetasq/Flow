//
//  UIView+Utils.swift
//  
//
//  Created by Zhu Shengqi on 2019/9/5.
//

import Foundation
import UIKit

extension UIView {
  
  public func takeSnapshot(useGPU: Bool) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
    defer {
      UIGraphicsEndImageContext()
    }
    
    if useGPU {
      self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
    } else {
      self.layer.render(in: UIGraphicsGetCurrentContext()!)
    }
    
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    return image
  }
  
}
