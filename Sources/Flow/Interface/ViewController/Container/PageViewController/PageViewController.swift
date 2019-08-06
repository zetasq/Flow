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
  private let _contentLayouter: PageViewControllerContentLayouting
  
  public private(set) var allPages: [UIViewController]
  
  private var _onboardPages: Set<UIViewController>
  private var _onboardPageVisibilityMap: [UIViewController: OnboardPageVisibility]
  
  private var _currentIndex: Int
  
  private var _currentIndexBeforeViewLayout: Int
  
  private let _scrollView: UIScrollView
  
  // MARK: - Init & deinit
  public init(contentLayouter: PageViewControllerContentLayouting = HorizontalPagingLayouter()) {
    self._contentLayouter = contentLayouter
    self.allPages = []
    self._onboardPages = []
    self._onboardPageVisibilityMap = [:]
    self._currentIndex = 0
    self._currentIndexBeforeViewLayout = 0
    
    self._scrollView = UIScrollView()
    self._scrollView.isPagingEnabled = true
    
    self._scrollView.alwaysBounceHorizontal = contentLayouter.shouldScrollViewAlwaysBounceHorizontal
    self._scrollView.alwaysBounceVertical = contentLayouter.shouldScrollViewAlwaysBounceVertical
    
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
    
    _scrollView.frame = view.bounds
    _scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    view.addSubview(_scrollView)
    _scrollView.delegate = self
    
    updateBouncingBehavior()
    
    updateCurrentIndexIfNeeded()
    tilePagesRegardingCurrentIndex()
    performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: self.appearanceState)
  }
  
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    // We should keep the same index after view.bounds changes. e.g. If the user are watching a series of videos, it is an unexpected behavior that currrent video changes after screen rotation.
    // But if the scrollView is still decelerating when the device is rotated, the index will be incorrect nonetheless.
    self._currentIndexBeforeViewLayout = self._currentIndex
  }
  
  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    self.setCurrentIndex(_currentIndexBeforeViewLayout, animated: false)
    
    updateContentSize()
    
    updateCurrentIndexIfNeeded()
    tilePagesRegardingCurrentIndex()
    performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: self.appearanceState)
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
  
  public func appendPages(_ newPages: [UIViewController]) {
    allPages.append(contentsOf: newPages)
    
    if self.isViewLoaded {
      tilePagesRegardingCurrentIndex()
      performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: self.appearanceState)
    }
  }
  
  public func appendPage(_ newPage: UIViewController) {
    appendPages([newPage])
  }
  
  public func removePage(at index: Int) {
    guard let pageToRemove = page(at: index) else {
      return
    }
    
    allPages.remove(at: index)
    transitionAppearanceToDisappearForOnboardPage(pageToRemove)
    movePageOutOfHierarchyIfPossible(pageToRemove)
    _onboardPages.remove(pageToRemove)
    _onboardPageVisibilityMap[pageToRemove] = nil
    
    tilePagesRegardingCurrentIndex()
    performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: self.appearanceState)
    cleanUpDistantPages()
  }
  
  func setCurrentIndex(_ newCurrentIndex: Int, animated: Bool) {
    guard isIndexValid(newCurrentIndex) else {
      return
    }
    
    let targetContentOffset = self._contentLayouter.calculatePreferredContentOffset(forDisplayingPageAt: newCurrentIndex, containerBounds: view.bounds)
    self._scrollView.setContentOffset(targetContentOffset, animated: animated)
  }
  
  // MARK: - Helper methods
  private func page(at index: Int) -> UIViewController? {
    guard isIndexValid(index) else {
      return nil
    }
    
    return allPages[index]
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
  
  private func updateContentSize() {
    assert(isViewLoaded)
    
    _scrollView.contentSize = self._contentLayouter.calculateCanvasSize(containerBounds: view.bounds, pagesCount: allPages.count)
  }
  
  private func updateBouncingBehavior() {
    self._scrollView.alwaysBounceHorizontal = self._contentLayouter.shouldScrollViewAlwaysBounceHorizontal
    self._scrollView.alwaysBounceVertical = self._contentLayouter.shouldScrollViewAlwaysBounceVertical
  }
  
  private func updateCurrentIndexIfNeeded() {
    guard view.bounds.width > 0 && view.bounds.height > 0 else {
      return
    }
    
    let calculatedIndex = self._contentLayouter.calculateCurrentIndex(containerBounds: view.bounds, contentOffset: _scrollView.contentOffset)
    
    if calculatedIndex != _currentIndex {
      _currentIndex = calculatedIndex
    }
  }
  
  private func isIndexValid(_ index: Int) -> Bool {
    return (allPages.startIndex..<allPages.endIndex).contains(index)
  }
  
  private func tilePage(at index: Int) {
    guard isIndexValid(index) else {
      return
    }
    
    let page = allPages[index]
    movePageIntoHierarchyIfPossible(page)
    _onboardPages.insert(page)
    
    page.view.frame = self._contentLayouter.calculatePageFrame(at: index, containerBounds: view.bounds)
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
      transitionAppearanceToDisappearForOnboardPage(page)
      movePageOutOfHierarchyIfPossible(page)
      _onboardPages.remove(page)
      _onboardPageVisibilityMap[page] = nil
    }
  }
  
}

// MARK: - UIScrollViewDelegate
extension PageViewController: UIScrollViewDelegate {
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    updateCurrentIndexIfNeeded()
    tilePagesRegardingCurrentIndex()
    performAppearanceUpdateAfterPossibleTiling(containerAppearanceState: self.appearanceState)
    cleanUpDistantPages()
  }
  
}
