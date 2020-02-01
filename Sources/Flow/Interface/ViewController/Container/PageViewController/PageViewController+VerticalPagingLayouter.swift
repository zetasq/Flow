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
    
    public func calculateCanvasSize(containerSize: CGSize, pagesCount: Int) -> CGSize {
      return CGSize(width: containerSize.width, height: containerSize.height * CGFloat(pagesCount))
    }
    
    public func calculateCurrentIndex(containerSize: CGSize, contentOffset: CGPoint) -> Int {
      return Int((contentOffset.y / containerSize.height).rounded())
    }
    
    public func calculatePageFrame(at index: Int, containerSize: CGSize) -> CGRect {
      return CGRect(x: 0, y: CGFloat(index) * containerSize.height, width: containerSize.width, height: containerSize.height)
    }
  
    public func calculatePreferredContentOffset(forDisplayingPageAt index: Int, containerSize: CGSize) -> CGPoint {
      let pageFrame = self.calculatePageFrame(at: index, containerSize: containerSize)
      
      return pageFrame.origin
    }
    
  }
  
}
