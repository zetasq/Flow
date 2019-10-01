//
//  CGRect+Utils.swift
//  
//
//  Created by Zhu Shengqi on 1/10/2019.
//

import Foundation
import UIKit

extension CGRect {
  
  public func transform(from sourceRect: CGRect) -> CGAffineTransform {
    let translationTranform = CGAffineTransform(translationX: self.midX - sourceRect.midX, y: self.midY - sourceRect.midY)
    let scaleTransform = CGAffineTransform(scaleX: self.width / sourceRect.width, y: self.height / sourceRect.height)
    
    return scaleTransform.concatenating(translationTranform)
  }
  
}
