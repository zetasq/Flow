//
//  PageViewControllerContentLayouting.swift
//  
//
//  Created by Zhu Shengqi on 2019/8/6.
//

import Foundation
import UIKit

public protocol PageViewControllerContentLayouting {
  
  var shouldScrollViewAlwaysBounceHorizontal: Bool { get }
  
  var shouldScrollViewAlwaysBounceVertical: Bool { get }
  
  func calculateCanvasSize(containerBounds: CGRect, pagesCount: Int) -> CGSize

  func calculateCurrentIndex(containerBounds: CGRect, contentOffset: CGPoint) -> Int
  
  func calculatePageFrame(at index: Int, containerBounds: CGRect) -> CGRect
  
  func calculatePreferredContentOffset(forDisplayingPageAt index: Int, containerBounds: CGRect) -> CGPoint
  
}


