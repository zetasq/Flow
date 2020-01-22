//
//  PageViewController.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/30.
//

import UIKit

open class PageViewController: UIViewController {
  
  // MARK: - Subtypes
  private enum OnboardPageVisibility {
    
    case hidden
    
    case partial
    
    case full
    
  }
  
  // MARK: - Properties
  private let _contentLayouter: PageViewControllerContentLayouting
  
  public private(set) var allPages: [UIViewController] {
    didSet {
      if isViewLoaded {
        updateContentSize()
      }
    }
  }
  
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
    fatalError("\(#function) has not been implemented")
  }
  
  // MARK: - View life cycle
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    _scrollView.frame = view.bounds // We will still update scrollView's frame in viewDidLayoutSubviews
    view.addSubview(_scrollView)
    _scrollView.delegate = self
    
    updateBouncingBehavior()
    
    updateCurrentIndexIfNeeded()
    tilePagesRegardingCurrentIndex()
    performAppearStateUpdateAfterPossibleTiling()
  }
  
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    // We should keep the same index after view.bounds changes. e.g. If the user are watching a series of videos, it is an unexpected behavior that currrent video changes after screen rotation.
    // But if the scrollView is still decelerating when the device is being rotated, the index will be incorrect nonetheless.
    self._currentIndexBeforeViewLayout = self._currentIndex
  }
  
  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    _scrollView.frame = view.bounds // We cannot rely on UIView's auto-resizing layout algorithm, due to its sub-pixel dimension issues.
    
    self.setCurrentIndex(_currentIndexBeforeViewLayout, animated: false)
    
    updateContentSize()
    
    updateCurrentIndexIfNeeded()
    tilePagesRegardingCurrentIndex()
    performAppearStateUpdateAfterPossibleTiling()
    cleanUpDistantPages()
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    performAppearStateUpdateAfterPossibleTiling()
  }
  
  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    performAppearStateUpdateAfterPossibleTiling()
  }
  
  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    performAppearStateUpdateAfterPossibleTiling()
  }
  
  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    performAppearStateUpdateAfterPossibleTiling()
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
      performAppearStateUpdateAfterPossibleTiling()
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
    transitionAppearStateToDidDisappearForOnboardPage(pageToRemove)
    movePageOutOfHierarchyIfPossible(pageToRemove)
    _onboardPages.remove(pageToRemove)
    _onboardPageVisibilityMap[pageToRemove] = nil
    
    tilePagesRegardingCurrentIndex()
    performAppearStateUpdateAfterPossibleTiling()
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

  private func calculateTargetAppearStateForOnboardPage(_ onboardPage: UIViewController, pageVisibility: OnboardPageVisibility, containerAppearState: UIViewController.AppearState) -> UIViewController.AppearState {
    let currentAppearState = onboardPage.appearState
    
    let newAppearState: UIViewController.AppearState
    
    switch currentAppearState {
    case .didDisappear:
      switch pageVisibility {
      case .hidden:
        newAppearState = .didDisappear
      case .partial:
        switch containerAppearState {
        case .didDisappear:
          newAppearState = .didDisappear
        case .willAppear, .didAppear:
          newAppearState = .willAppear
        case .willDisappear:
          newAppearState = .willDisappear
        }
      case .full:
        switch containerAppearState {
        case .didDisappear:
          newAppearState = .didDisappear
        case .willAppear:
          newAppearState = .willAppear
        case .didAppear:
          newAppearState = .didAppear
        case .willDisappear:
          newAppearState = .willDisappear
        }
      }
    case .willAppear:
      switch pageVisibility {
      case .hidden:
        newAppearState = .didDisappear
      case .partial:
        switch containerAppearState {
        case .didDisappear:
          newAppearState = .didDisappear
        case .willAppear, .didAppear:
          newAppearState = .willAppear
        case .willDisappear:
          newAppearState = .willDisappear
        }
      case .full:
        switch containerAppearState {
        case .didDisappear:
          newAppearState = .didDisappear
        case .willAppear:
          newAppearState = .willAppear
        case .didAppear:
          newAppearState = .didAppear
        case .willDisappear:
          newAppearState = .willDisappear
        }
      }
    case .didAppear:
      switch pageVisibility {
      case .hidden:
        newAppearState = .didDisappear
      case .partial:
        switch containerAppearState {
        case .didDisappear:
          newAppearState = .didDisappear
        case .willAppear:
          newAppearState = .willAppear
        case .didAppear, .willDisappear:
          newAppearState = .willDisappear
        }
      case .full:
        switch containerAppearState {
        case .didDisappear:
          newAppearState = .didDisappear
        case .willAppear:
          newAppearState = .willAppear
        case .didAppear:
          newAppearState = .didAppear
        case .willDisappear:
          newAppearState = .willDisappear
        }
      }
    case .willDisappear:
      switch pageVisibility {
      case .hidden:
        newAppearState = .didDisappear
      case .partial:
        switch containerAppearState {
        case .didDisappear:
          newAppearState = .didDisappear
        case .willAppear:
          newAppearState = .willAppear
        case .didAppear, .willDisappear:
          newAppearState = .willDisappear
        }
      case .full:
        switch containerAppearState {
        case .didDisappear:
          newAppearState = .didDisappear
        case .willAppear:
          newAppearState = .willAppear
        case .didAppear:
          newAppearState = .didAppear
        case .willDisappear:
          newAppearState = .willDisappear
        }
      }
    }
    
    return newAppearState
  }
  
  private func transitionAppearStateToTargetStateForOnboardPage(_ onboardPage: UIViewController, targetAppearState: UIViewController.AppearState) {
    assert(onboardPage.parent == self)
    
    let currentAppearState = onboardPage.appearState
    
    switch (currentAppearState, targetAppearState) {
    case (.willAppear, .willAppear):
      break
    case (.willAppear, .didAppear):
      onboardPage.endAppearanceTransition()
    case (.willAppear, .willDisappear):
      onboardPage.beginAppearanceTransition(false, animated: true)
    case (.willAppear, .didDisappear):
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
    case (.willDisappear, .willAppear):
      break
    case (.willDisappear, .didAppear):
      onboardPage.beginAppearanceTransition(true, animated: false)
      onboardPage.endAppearanceTransition()
    case (.willDisappear, .willDisappear):
      break
    case (.willDisappear, .didDisappear):
      onboardPage.endAppearanceTransition()
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
  
  private func transitionAppearStateToDidDisappearForOnboardPage(_ onboardPage: UIViewController) {
    assert(onboardPage.parent == self)
    
    switch onboardPage.appearState {
    case .didDisappear:
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
  
  private func performAppearStateUpdateAfterPossibleTiling() {
    var newVisibilityMap: [UIViewController: OnboardPageVisibility] = [:]
    
    for onboardViewController in _onboardPages {
      newVisibilityMap[onboardViewController] = calculateVisibilityForOnboardPage(onboardViewController)
    }
    
    // This method is only called after possible tiling, so there should only be new onboard view controllers.
    assert(Set(newVisibilityMap.keys).isSuperset(of: Set(_onboardPageVisibilityMap.keys)))
    
    var viewControllerTargetAppearStatePairs: [(UIViewController, UIViewController.AppearState)] = []
    
    let containerAppearState = self.appearState
    
    for (viewController, visibility) in newVisibilityMap {
      let targetAppearState = calculateTargetAppearStateForOnboardPage(viewController, pageVisibility: visibility, containerAppearState: containerAppearState)
      
      viewControllerTargetAppearStatePairs.append((viewController, targetAppearState))
    }
    
    // We want willDisappear/didDisappear to be called first, so some critical resource may be released and then be acquired.
    for (viewController, targetAppearState) in viewControllerTargetAppearStatePairs.sorted(by: { $0.1.orderForViewControllerTransitioning < $1.1.orderForViewControllerTransitioning }) {
      transitionAppearStateToTargetStateForOnboardPage(viewController, targetAppearState: targetAppearState)
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
      transitionAppearStateToDidDisappearForOnboardPage(page)
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
    performAppearStateUpdateAfterPossibleTiling()
    cleanUpDistantPages()
  }
  
}
