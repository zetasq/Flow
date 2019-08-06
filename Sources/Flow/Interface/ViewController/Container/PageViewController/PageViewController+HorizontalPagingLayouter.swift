//
//  File.swift
//  
//
//  Created by Zhu Shengqi on 2019/8/6.
//

import Foundation
import UIKit

extension PageViewController {
  
  public struct HorizontalPagingLayouter: PageViewControllerContentLayouting {
    
    public init() {}
    
    public var shouldScrollViewAlwaysBounceHorizontal: Bool {
      return true
    }
    
    public var shouldScrollViewAlwaysBounceVertical: Bool {
      return false
    }
    
    public func calculateCanvasSize(containerBounds: CGRect, pagesCount: Int) -> CGSize {
      return CGSize(width: containerBounds.width * CGFloat(pagesCount), height: containerBounds.height)
    }
    
    public func calculateCurrentIndex(containerBounds: CGRect, contentOffset: CGPoint) -> Int {
      return Int((contentOffset.x / containerBounds.width).rounded())
    }
    
    public func calculatePageFrame(at index: Int, containerBounds: CGRect) -> CGRect {
      return CGRect(x: CGFloat(index) * containerBounds.width, y: 0, width: containerBounds.width, height: containerBounds.height)
    }

    public func calculatePreferredContentOffset(forDisplayingPageAt index: Int, containerBounds: CGRect) -> CGPoint {
      let pageFrame = self.calculatePageFrame(at: index, containerBounds: containerBounds)
      
      return pageFrame.origin
    }
  }
  
}
