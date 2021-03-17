//
//  File.swift
//  
//
//  Created by Zhu Shengqi on 2019/8/6.
//

#if os(iOS)

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
    
    public func calculateCanvasSize(containerSize: CGSize, pagesCount: Int) -> CGSize {
      return CGSize(width: containerSize.width * CGFloat(pagesCount), height: containerSize.height)
    }
    
    public func calculateCurrentIndex(containerSize: CGSize, contentOffset: CGPoint) -> Int {
      return Int((contentOffset.x / containerSize.width).rounded())
    }
    
    public func calculatePageFrame(at index: Int, containerSize: CGSize) -> CGRect {
      return CGRect(x: CGFloat(index) * containerSize.width, y: 0, width: containerSize.width, height: containerSize.height)
    }

    public func calculatePreferredContentOffset(forDisplayingPageAt index: Int, containerSize: CGSize) -> CGPoint {
      let pageFrame = self.calculatePageFrame(at: index, containerSize: containerSize)
      
      return pageFrame.origin
    }
  }
  
}

#endif
