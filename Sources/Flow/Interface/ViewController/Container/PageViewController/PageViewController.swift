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
  
  private enum OnboardViewControllerVisibility {
    
    case hidden
    
    case partial
    
    case full
    
  }
  
  // MARK: - Properties
  public let navigationOrientation: NavigationOrientation
  
  private var _allPages: [UIViewController]
  
  private var _onboardViewControllerSet: Set<UIViewController>
  private var _onboardViewControllerVisibilityMap: [UIViewController: OnboardViewControllerVisibility]
  
  private var _currentIndex: Int
  
  private let _scrollView: UIScrollView
  
  // MARK: - Init & deinit
  public init(navigationOrientation: NavigationOrientation, initialViewControllers: [UIViewController]) {
    self.navigationOrientation = navigationOrientation
    self._allPages = initialViewControllers
    self._onboardViewControllerSet = []
    self._onboardViewControllerVisibilityMap = [:]
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
    
    self._scrollView.delegate = self
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View life cycle
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(_scrollView)
    
    tilePageRegardingCurrentIndex()
    updateAppearanceForPages(containerAppearanceState: self.appearanceState)
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
    
    tilePageRegardingCurrentIndex()
    updateAppearanceForPages(containerAppearanceState: self.appearanceState)
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateAppearanceForPages(containerAppearanceState: .willAppear)
  }
  
  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    updateAppearanceForPages(containerAppearanceState: .didAppear)
  }
  
  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    updateAppearanceForPages(containerAppearanceState: .willDisappear)
  }
  
  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    updateAppearanceForPages(containerAppearanceState: .didDisappear)
  }
  
  // MARK: - Appearance Overrides
  open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
    return false
  }
  
  // MARK: - Public methods
  public var currentPage: UIViewController? {
    return viewController(at: _currentIndex)
  }
  
  // MARK: - Helper methods
  private func viewController(at index: Int) -> UIViewController? {
    guard isIndexValid(index) else {
      return nil
    }
    
    return _allPages[index]
  }
  
  private func placeViewControllerOnboardIfNeeded(at index: Int) {
    guard isIndexValid(index) else {
      return
    }
    
    let viewController = _allPages[index]
    
    guard !_onboardViewControllerSet.contains(viewController) else {
      return
    }
    
    movePageViewControllerIntoHierarchy(viewController)
    _onboardViewControllerSet.insert(viewController)
  }
  
  private func placeViewControllerOffboardIfNeeded(at index: Int) {
    guard isIndexValid(index) else {
      return
    }
    
    let viewController = _allPages[index]
    
    guard _onboardViewControllerSet.contains(viewController) else {
      return
    }
    
    movePageViewControllerOutOfHierarchy(viewController)
    _onboardViewControllerSet.remove(viewController)
  }
  
  private func movePageViewControllerIntoHierarchy(_ viewController: UIViewController) {
    assert(viewController.parent == nil)
    
    addChild(viewController)
    _scrollView.addSubview(viewController.view)
    viewController.didMove(toParent: self)
  }
  
  private func movePageViewControllerOutOfHierarchy(_ viewController: UIViewController) {
    assert(viewController.parent == self)
    
    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
  }
  
  private func isIndexValid(_ index: Int) -> Bool {
    return (_allPages.startIndex..<_allPages.endIndex).contains(index)
  }
  
  private func tilePage(at index: Int) {
    guard isIndexValid(index) else {
      return
    }
    
    placeViewControllerOnboardIfNeeded(at: index)
    
    if let targetViewController = viewController(at: index) {
      let targetFrame: CGRect
      
      switch self.navigationOrientation {
      case .horizontal:
        targetFrame = CGRect(x: CGFloat(index) * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
      case .vertical:
        targetFrame = CGRect(x: 0, y: CGFloat(index) * view.bounds.height, width: view.bounds.width, height: view.bounds.height)
      }
      
      targetViewController.view.frame = targetFrame
    }
  }
  
  private func tilePageRegardingCurrentIndex() {
    tilePage(at: _currentIndex - 1)
    tilePage(at: _currentIndex)
    tilePage(at: _currentIndex + 1)
  }
  
  private func updateAppearanceForPages(containerAppearanceState: ViewControllerAppearanceState) {
    var newVisibilityMap: [UIViewController: OnboardViewControllerVisibility] = [:]
    
    let containerBounds = self.view.bounds
    
    for onboardViewController in _onboardViewControllerSet {
      assert(onboardViewController.isViewLoaded)
      
      let frameInContainer = onboardViewController.view.convert(onboardViewController.view.bounds, to: self.view)
      
      if !containerBounds.intersects(frameInContainer) {
        newVisibilityMap[onboardViewController] = .hidden
      } else if !containerBounds.contains(frameInContainer) {
        newVisibilityMap[onboardViewController] = .partial
      } else {
        newVisibilityMap[onboardViewController] = .full
      }
    }
    
    // Handle moved-offboard view controllers
    for oldOnboardViewController in _onboardViewControllerVisibilityMap.keys {
      if newVisibilityMap[oldOnboardViewController] == nil {
        switch oldOnboardViewController.appearanceState {
        case .initial:
          break
        case .willAppear, .didAppear:
          oldOnboardViewController.beginAppearanceTransition(false, animated: false)
          oldOnboardViewController.endAppearanceTransition()
        case .willDisappear:
          oldOnboardViewController.endAppearanceTransition()
        case .didDisappear:
          break
        }
      }
    }
    
    for (currentOnboardViewController, visibility) in newVisibilityMap {
      let currentAppearanceState = currentOnboardViewController.appearanceState
      
      let newAppearanceState: ViewControllerAppearanceState
      
      if _onboardViewControllerVisibilityMap[currentOnboardViewController] != nil {
        // Handle possibly updated appearance state
        switch currentAppearanceState {
        case .initial, .didDisappear:
          switch visibility {
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
          switch visibility {
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
          switch visibility {
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
          switch visibility {
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
      } else {
        // Handle moved-onboard view controllers
        assert(currentOnboardViewController.appearanceState == .initial || currentOnboardViewController.appearanceState == .didDisappear)
        
        switch visibility {
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
      }
      
      switch (currentAppearanceState, newAppearanceState) {
      case (.initial, .initial):
        break
      case (.initial, .willAppear):
        currentOnboardViewController.beginAppearanceTransition(true, animated: true)
      case (.initial, .didAppear):
        currentOnboardViewController.beginAppearanceTransition(true, animated: false)
        currentOnboardViewController.endAppearanceTransition()
      case (.initial, .willDisappear):
        currentOnboardViewController.beginAppearanceTransition(true, animated: false)
        currentOnboardViewController.endAppearanceTransition()
        currentOnboardViewController.beginAppearanceTransition(false, animated: true)
      case (.initial, .didDisappear):
        break
      case (.willAppear, .initial):
        assertionFailure()
        currentOnboardViewController.beginAppearanceTransition(false, animated: false)
        currentOnboardViewController.endAppearanceTransition()
      case (.willAppear, .willAppear):
        break
      case (.willAppear, .didAppear):
        currentOnboardViewController.endAppearanceTransition()
      case (.willAppear, .willDisappear):
        currentOnboardViewController.beginAppearanceTransition(false, animated: true)
      case (.willAppear, .didDisappear):
        currentOnboardViewController.beginAppearanceTransition(false, animated: false)
        currentOnboardViewController.endAppearanceTransition()
      case (.didAppear, .initial):
        assertionFailure()
        currentOnboardViewController.beginAppearanceTransition(false, animated: false)
        currentOnboardViewController.endAppearanceTransition()
      case (.didAppear, .willAppear):
        assertionFailure()
        currentOnboardViewController.beginAppearanceTransition(false, animated: true)
      case (.didAppear, .didAppear):
        break
      case (.didAppear, .willDisappear):
        currentOnboardViewController.beginAppearanceTransition(false, animated: true)
      case (.didAppear, .didDisappear):
        currentOnboardViewController.beginAppearanceTransition(false, animated: false)
        currentOnboardViewController.endAppearanceTransition()
      case (.willDisappear, .initial):
        assertionFailure()
        currentOnboardViewController.endAppearanceTransition()
      case (.willDisappear, .willAppear):
        break
      case (.willDisappear, .didAppear):
        currentOnboardViewController.beginAppearanceTransition(true, animated: false)
        currentOnboardViewController.endAppearanceTransition()
      case (.willDisappear, .willDisappear):
        break
      case (.willDisappear, .didDisappear):
        currentOnboardViewController.endAppearanceTransition()
      case (.didDisappear, .initial):
        assertionFailure()
      case (.didDisappear, .willAppear):
        currentOnboardViewController.beginAppearanceTransition(true, animated: true)
      case (.didDisappear, .didAppear):
        currentOnboardViewController.beginAppearanceTransition(true, animated: false)
        currentOnboardViewController.endAppearanceTransition()
      case (.didDisappear, .willDisappear):
        currentOnboardViewController.beginAppearanceTransition(true, animated: true)
      case (.didDisappear, .didDisappear):
        break
      }
    }
    
    _onboardViewControllerVisibilityMap = newVisibilityMap
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
      tilePageRegardingCurrentIndex()
    }
    
    updateAppearanceForPages(containerAppearanceState: self.appearanceState)
  }
  
}
