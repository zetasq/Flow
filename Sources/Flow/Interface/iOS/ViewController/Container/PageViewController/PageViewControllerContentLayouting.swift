//
//  PageViewControllerContentLayouting.swift
//  
//
//  Created by Zhu Shengqi on 2019/8/6.
//

#if os(iOS)

import Foundation
import UIKit

public protocol PageViewControllerContentLayouting {
  
  var shouldScrollViewAlwaysBounceHorizontal: Bool { get }
  
  var shouldScrollViewAlwaysBounceVertical: Bool { get }
  
  func calculateCanvasSize(containerSize: CGSize, pagesCount: Int) -> CGSize

  func calculateCurrentIndex(containerSize: CGSize, contentOffset: CGPoint) -> Int
  
  func calculatePageFrame(at index: Int, containerSize: CGSize) -> CGRect
  
  func calculatePreferredContentOffset(forDisplayingPageAt index: Int, containerSize: CGSize) -> CGPoint
  
}

#endif
