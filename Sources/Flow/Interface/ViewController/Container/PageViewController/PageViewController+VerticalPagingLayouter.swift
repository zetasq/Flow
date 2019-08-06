//
//  File.swift
//  
//
//  Created by Zhu Shengqi on 2019/8/6.
//

import Foundation
import UIKit

extension PageViewController {
  
  public struct VerticalPagingLayouter: PageViewControllerContentLayouting {
    
    public init() {}

    public var shouldScrollViewAlwaysBounceHorizontal: Bool {
      return false
    }
    
    public var shouldScrollViewAlwaysBounceVertical: Bool {
      return true
    }
    
    public func calculateCanvasSize(containerBounds: CGRect, pagesCount: Int) -> CGSize {
      return CGSize(width: containerBounds.width, height: containerBounds.height * CGFloat(pagesCount))
    }
    
    public func calculateCurrentIndex(containerBounds: CGRect, contentOffset: CGPoint) -> Int {
      return Int((contentOffset.y / containerBounds.height).rounded())
    }
    
    public func calculatePageFrame(at index: Int, containerBounds: CGRect) -> CGRect {
      return CGRect(x: 0, y: CGFloat(index) * containerBounds.height, width: containerBounds.width, height: containerBounds.height)
    }
  
    public func calculatePreferredContentOffset(forDisplayingPageAt index: Int, containerBounds: CGRect) -> CGPoint {
      let pageFrame = self.calculatePageFrame(at: index, containerBounds: containerBounds)
      
      return pageFrame.origin
    }
    
  }
  
}
