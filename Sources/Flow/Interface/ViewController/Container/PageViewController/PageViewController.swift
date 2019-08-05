//
//  PageViewController.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/30.
//

import UIKit
import FlowObjC

open class PageViewController: UIViewController {
  
  // MARK: - Subtypes
  public enum NavigationOrientation {
    
    case horizontal
    
    case vertical
    
  }
  
  private enum OnboardPageVisibility {
    
    case hidden
    
    case partial
    
    case full
    
  }
  
  // MARK: - Properties
  public let navigationOrientation: NavigationOrientation
  
  private var _allPages: [UIViewController]
  
  private var _onboardPages: Set<UIViewController>
  private var _onboardPageVisibilityMap: [UIViewController: OnboardPageVisibility]
  
  private var _currentIndex: Int
  
  private let _scrollView: UIScrollView
  
  // MARK: - Init & deinit
  public init(navigationOrientation: NavigationOrientation, initialPages: [UIViewController]) {
    self.navigationOrientation = navigationOrientation
    self._allPages = initialPages
    self._onboardPages = []
    self._onboardPageVisibilityMap = [:]
    self._currentIndex = 0
    
    self._scrollView = UIScrollView()
    self._scrollView.isPagingEnabled = true
    
    switch navigationOrientation {
    case .horizontal:
      self._scrollView.alwaysBounceHorizontal = true
    case .vertical:
      self._scrollView.alwaysBounceVertical = true
    }
    
    self._scrollView.contentInsetAdjustmentBehavior = .never
    
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View life cycle
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(_scrollView)
    _scrollView.delegate = self
    
    tilePagesRegardingCurrentIndex()
    performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: self.appearanceState)
  }
  
  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let currentBounds = view.bounds
    
    _scrollView.frame = currentBounds
    
    switch self.navigationOrientation {
    case .horizontal:
      let contentSize = CGSize(width: currentBounds.width * CGFloat(_allPages.count), height: currentBounds.height)
      _scrollView.contentSize = contentSize
    case .vertical:
      let contentSize = CGSize(width: currentBounds.width, height: currentBounds.height * CGFloat(_allPages.count))
      _scrollView.contentSize = contentSize
    }
    
    tilePagesRegardingCurrentIndex()
    performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: self.appearanceState)
    
    // viewDidLayoutSubviews may be called due to bounds change, so we should remove pages which are not adjacent to current index.
    cleanUpDistantPages()
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: .willAppear)
  }
  
  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: .didAppear)
  }
  
  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: .willDisappear)
  }
  
  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: .didDisappear)
  }
  
  // MARK: - Appearance Overrides
  open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
    return false
  }
  
  // MARK: - Public methods
  public var currentPage: UIViewController? {
    return page(at: _currentIndex)
  }
  
  // MARK: - Helper methods
  private func page(at index: Int) -> UIViewController? {
    guard isIndexValid(index) else {
      return nil
    }
    
    return _allPages[index]
  }
  
  private func movePageIntoHierarchyIfPossible(_ page: UIViewController) {
    guard page.parent == nil else {
      return
    }
    
    addChild(page)
    _scrollView.addSubview(page.view)
    page.didMove(toParent: self)
  }
  
  private func movePageOutOfHierarchyIfPossible(_ page: UIViewController) {
    guard page.parent == self else {
      return
    }
    
    page.willMove(toParent: nil)
    page.view.removeFromSuperview()
    page.removeFromParent()
  }
  
  private func calculateVisibilityForOnboardPage(_ onboardPage: UIViewController) -> OnboardPageVisibility {
    assert(onboardPage.isViewLoaded)
    assert(onboardPage.parent == self)
    
    let frameInContainer = onboardPage.view.convert(onboardPage.view.bounds, to: self.view)
    
    let containerBounds = self.view.bounds
    
    if !containerBounds.intersects(frameInContainer) {
      return .hidden
    } else if !containerBounds.contains(frameInContainer) {
      return .partial
    } else {
      return .full
    }
  }

  private func calculateTargetAppearanceStateForOnboardPage(_ onboardPage: UIViewController, pageVisibility: OnboardPageVisibility, containerAppearanceState: ViewControllerAppearanceState) -> ViewControllerAppearanceState {
    let currentAppearanceState = onboardPage.appearanceState
    
    let newAppearanceState: ViewControllerAppearanceState
    
    switch currentAppearanceState {
    case .initial, .didDisappear:
      switch pageVisibility {
      case .hidden:
        newAppearanceState = currentAppearanceState
      case .partial:
        switch containerAppearanceState {
        case .initial, .didDisappear:
          newAppearanceState = currentAppearanceState
        case .willAppear, .didAppear:
          newAppearanceState = .willAppear
        case .willDisappear:
          newAppearanceState = .willDisappear
        }
      case .full:
        switch containerAppearanceState {
        case .initial, .didDisappear:
          newAppearanceState = currentAppearanceState
        case .willAppear:
          newAppearanceState = .willAppear
        case .didAppear:
          newAppearanceState = .didAppear
        case .willDisappear:
          newAppearanceState = .willDisappear
        }
      }
    case .willAppear:
      switch pageVisibility {
      case .hidden:
        newAppearanceState = .didDisappear
      case .partial:
        switch containerAppearanceState {
        case .initial, .didDisappear:
          newAppearanceState = .didDisappear
        case .willAppear, .didAppear:
          newAppearanceState = .willAppear
        case .willDisappear:
          newAppearanceState = .willDisappear
        }
      case .full:
        switch containerAppearanceState {
        case .initial, .didDisappear:
          newAppearanceState = .didDisappear
        case .willAppear:
          newAppearanceState = .willAppear
        case .didAppear:
          newAppearanceState = .didAppear
        case .willDisappear:
          newAppearanceState = .willDisappear
        }
      }
    case .didAppear:
      switch pageVisibility {
      case .hidden:
        newAppearanceState = .didDisappear
      case .partial:
        switch containerAppearanceState {
        case .initial, .didDisappear:
          newAppearanceState = .didDisappear
        case .willAppear:
          newAppearanceState = .willAppear
        case .didAppear, .willDisappear:
          newAppearanceState = .willDisappear
        }
      case .full:
        switch containerAppearanceState {
        case .initial, .didDisappear:
          newAppearanceState = .didDisappear
        case .willAppear:
          newAppearanceState = .willAppear
        case .didAppear:
          newAppearanceState = .didAppear
        case .willDisappear:
          newAppearanceState = .willDisappear
        }
      }
    case .willDisappear:
      switch pageVisibility {
      case .hidden:
        newAppearanceState = .didDisappear
      case .partial:
        switch containerAppearanceState {
        case .initial, .didDisappear:
          newAppearanceState = .didDisappear
        case .willAppear:
          newAppearanceState = .willAppear
        case .didAppear, .willDisappear:
          newAppearanceState = .willDisappear
        }
      case .full:
        switch containerAppearanceState {
        case .initial, .didDisappear:
          newAppearanceState = .didDisappear
        case .willAppear:
          newAppearanceState = .willAppear
        case .didAppear:
          newAppearanceState = .didAppear
        case .willDisappear:
          newAppearanceState = .willDisappear
        }
      }
    }
    
    return newAppearanceState
  }
  
  private func transitionAppearanceToTargetStateForOnboardPage(_ onboardPage: UIViewController, targetAppearanceState: ViewControllerAppearanceState) {
    assert(onboardPage.parent == self)
    
    let currentAppearanceState = onboardPage.appearanceState
    
    switch (currentAppearanceState, targetAppearanceState) {
    case (.initial, .initial):
      break
    case (.initial, .willAppear):
      onboardPage.beginAppearanceTransition(true, animated: true)
    case (.initial, .didAppear):
      onboardPage.beginAppearanceTransition(true, animated: false)
      onboardPage.endAppearanceTransition()
    case (.initial, .willDisappear):
      onboardPage.beginAppearanceTransition(true, animated: false)
      onboardPage.endAppearanceTransition()
      onboardPage.beginAppearanceTransition(false, animated: true)
    case (.initial, .didDisappear):
      break
    case (.willAppear, .initial):
      assertionFailure()
      onboardPage.beginAppearanceTransition(false, animated: false)
      onboardPage.endAppearanceTransition()
    case (.willAppear, .willAppear):
      break
    case (.willAppear, .didAppear):
      onboardPage.endAppearanceTransition()
    case (.willAppear, .willDisappear):
      onboardPage.beginAppearanceTransition(false, animated: true)
    case (.willAppear, .didDisappear):
      onboardPage.beginAppearanceTransition(false, animated: false)
      onboardPage.endAppearanceTransition()
    case (.didAppear, .initial):
      assertionFailure()
      onboardPage.beginAppearanceTransition(false, animated: false)
      onboardPage.endAppearanceTransition()
    case (.didAppear, .willAppear):
      assertionFailure()
      onboardPage.beginAppearanceTransition(false, animated: true)
    case (.didAppear, .didAppear):
      break
    case (.didAppear, .willDisappear):
      onboardPage.beginAppearanceTransition(false, animated: true)
    case (.didAppear, .didDisappear):
      onboardPage.beginAppearanceTransition(false, animated: false)
      onboardPage.endAppearanceTransition()
    case (.willDisappear, .initial):
      assertionFailure()
      onboardPage.endAppearanceTransition()
    case (.willDisappear, .willAppear):
      break
    case (.willDisappear, .didAppear):
      onboardPage.beginAppearanceTransition(true, animated: false)
      onboardPage.endAppearanceTransition()
    case (.willDisappear, .willDisappear):
      break
    case (.willDisappear, .didDisappear):
      onboardPage.endAppearanceTransition()
    case (.didDisappear, .initial):
      assertionFailure()
    case (.didDisappear, .willAppear):
      onboardPage.beginAppearanceTransition(true, animated: true)
    case (.didDisappear, .didAppear):
      onboardPage.beginAppearanceTransition(true, animated: false)
      onboardPage.endAppearanceTransition()
    case (.didDisappear, .willDisappear):
      onboardPage.beginAppearanceTransition(true, animated: true)
    case (.didDisappear, .didDisappear):
      break
    }
  }
  
  private func transitionAppearanceToDisappearForOnboardPage(_ onboardPage: UIViewController) {
    assert(onboardPage.parent == self)
    
    switch onboardPage.appearanceState {
    case .initial, .didDisappear:
      break
    case .willAppear, .didAppear:
      onboardPage.beginAppearanceTransition(false, animated: false)
      onboardPage.endAppearanceTransition()
    case .willDisappear:
      onboardPage.endAppearanceTransition()
    }
  }
  
  private func isIndexValid(_ index: Int) -> Bool {
    return (_allPages.startIndex..<_allPages.endIndex).contains(index)
  }
  
  private func tilePage(at index: Int) {
    guard isIndexValid(index) else {
      return
    }
    
    let page = _allPages[index]
    movePageIntoHierarchyIfPossible(page)
    _onboardPages.insert(page)
    
    let targetFrame: CGRect
    
    switch self.navigationOrientation {
    case .horizontal:
      targetFrame = CGRect(x: CGFloat(index) * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
    case .vertical:
      targetFrame = CGRect(x: 0, y: CGFloat(index) * view.bounds.height, width: view.bounds.width, height: view.bounds.height)
    }
    
    page.view.frame = targetFrame
  }

  private func tilePagesRegardingCurrentIndex() {
    tilePage(at: _currentIndex - 1)
    tilePage(at: _currentIndex)
    tilePage(at: _currentIndex + 1)
  }
  
  private func performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: ViewControllerAppearanceState) {
    var newVisibilityMap: [UIViewController: OnboardPageVisibility] = [:]
    
    for onboardViewController in _onboardPages {
      newVisibilityMap[onboardViewController] = calculateVisibilityForOnboardPage(onboardViewController)
    }
    
    // This method is only called after possible tiling, so there should only be new onboard view controllers.
    #if DEBUG
    assert(Set(newVisibilityMap.keys).isSuperset(of: Set(_onboardPageVisibilityMap.keys)))
    #endif
    
    var viewControllerTargetAppearanceStatePairs: [(UIViewController, ViewControllerAppearanceState)] = []
    
    for (viewController, visibility) in newVisibilityMap {
      let targetAppearanceState = calculateTargetAppearanceStateForOnboardPage(viewController, pageVisibility: visibility, containerAppearanceState: containerAppearanceState)
      
      viewControllerTargetAppearanceStatePairs.append((viewController, targetAppearanceState))
    }
    
    // We want willDisappear/didDisappear to be called first, so some critical resource may be released and acquired properly.
    for (viewController, targetAppearanceState) in viewControllerTargetAppearanceStatePairs.sorted(by: { $0.1.orderForViewControllerTransitioning < $1.1.orderForViewControllerTransitioning }) {
      transitionAppearanceToTargetStateForOnboardPage(viewController, targetAppearanceState: targetAppearanceState)
    }
    
    _onboardPageVisibilityMap = newVisibilityMap
  }
  
  private func cleanUpDistantPages() {
    var remainingPages: Set<UIViewController> = []
    
    if let previousPage = page(at: _currentIndex - 1) {
      remainingPages.insert(previousPage)
    }
    
    if let currentPage = page(at: _currentIndex) {
      remainingPages.insert(currentPage)
    }
    
    if let nextPage = page(at: _currentIndex + 1) {
      remainingPages.insert(nextPage)
    }
    
    var pagesToRemove: Set<UIViewController> = []
    
    for page in _onboardPages {
      if !remainingPages.contains(page) {
        pagesToRemove.insert(page)
      }
    }
    
    for page in pagesToRemove {
      movePageOutOfHierarchyIfPossible(page)
      _onboardPages.remove(page)
      _onboardPageVisibilityMap[page] = nil
    }
  }
  
}

// MARK: - UIScrollViewDelegate
extension PageViewController: UIScrollViewDelegate {
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard view.bounds.width > 0 && view.bounds.height > 0 else {
      return
    }
    
    let calculatedIndex: Int
    
    switch self.navigationOrientation {
    case .horizontal:
      calculatedIndex = Int((scrollView.contentOffset.x / view.bounds.width).rounded())
    case .vertical:
      calculatedIndex = Int((scrollView.contentOffset.y / view.bounds.height).rounded())
    }
    
    if calculatedIndex != _currentIndex {
      _currentIndex = calculatedIndex
      tilePagesRegardingCurrentIndex()
    }
    
    performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: self.appearanceState)
  }
  
}
