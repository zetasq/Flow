//
//  DisplayContainer.swift
//  
//
//  Created by Zhu Shengqi on 2020/2/9.
//

import Foundation
import UIKit

open class DisplayContainer<RootNode: DisplayNode>: _DisplayContainerBackingViewControllerDelegate {
  
  // MARK: - Properties
  private let _backingViewController: _DisplayContainerBackingViewController
  
  private let _rootNodeCreationBlock: () -> RootNode
  
  private var _lazyLoadedRootNode: RootNode?
  
  public final var rootNode: RootNode {
    if let node = _lazyLoadedRootNode {
      return node
    }
    
    _ = self._backingViewController.view
    return self._lazyLoadedRootNode!
  }
  
  public final var isRootNodeLoaded: Bool {
    return _lazyLoadedRootNode != nil
  }
  
  // MARK: - Init & deinit
  public init(rootNodeCreationBlock: @escaping () -> RootNode) {
    self._backingViewController = _DisplayContainerBackingViewController()
    self._rootNodeCreationBlock = rootNodeCreationBlock
    _backingViewController.delegate = self
  }
  
  // MARK: - _DisplayContainerBackingViewControllerDelegate
  internal func createRootViewForBackingViewController() -> UIView {
    assert(self._lazyLoadedRootNode == nil)
    
    let node = self._rootNodeCreationBlock()
    self._lazyLoadedRootNode = node
    return node.backingView
  }
  
  // MARK: - Child container management
  public final func addChild<ChildRootNode: DisplayNode, ChildDisplayContainer: DisplayContainer<ChildRootNode>>(_ childDisplayContainer: ChildDisplayContainer, nodeInstallationBlock: () -> Void) {
    self._backingViewController.addChild(childDisplayContainer._backingViewController)
    nodeInstallationBlock()
    childDisplayContainer._backingViewController.didMove(toParent: self._backingViewController)
  }
  
  public final func removeChild<ChildRootNode: DisplayNode, ChildDisplayContainer: DisplayContainer<ChildRootNode>>(_ childDisplayContainer: ChildDisplayContainer, nodeRemovalBlock: () -> Void) {
    childDisplayContainer._backingViewController.willMove(toParent: nil)
    nodeRemovalBlock()
    childDisplayContainer._backingViewController.removeFromParent()
  }
  
}

class TestContainer1: DisplayContainer<DisplayNode> {
  
}

class TestContainer2: DisplayContainer<TestNode> {
  
}

class TestNode: DisplayNode {
  
}

public func test() {
  let container = TestContainer1(rootNodeCreationBlock: { fatalError() })
  let child = TestContainer2(rootNodeCreationBlock: { fatalError() })
  container.addChild(child, nodeInstallationBlock: {})
}
