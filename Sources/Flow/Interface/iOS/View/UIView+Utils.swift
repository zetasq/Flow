//
//  UIView+Utils.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 10/7/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

extension UIView {

  public func makeSnapshot() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
    defer {
      UIGraphicsEndImageContext()
    }
    
    self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
    let snapshot = UIGraphicsGetImageFromCurrentImageContext()!
    
    return snapshot
  }
  
  public func makeSnapshotView() -> UIView {
    let snapshot = self.makeSnapshot()
    
    let snapshotView = UIImageView()
    snapshotView.image = snapshot
    snapshotView.contentMode = .scaleAspectFit
    snapshotView.frame = self.frame
    
    return snapshotView
  }
  
}
