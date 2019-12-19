//
//  DemoInlineEditableMenuView.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/19.
//

import Foundation
import UIKit

@objc
private protocol DemoInlineEditableMenuViewEditActions {
  
  func demoInlineEditableMenuViewEditActionA(_ sender: Any)
  
  func demoInlineEditableMenuViewEditActionB(_ sender: Any)
  
  func demoInlineEditableMenuViewEditActionC(_ sender: Any)
  
}

public protocol DemoInlineEditableMenuViewEditActionHandling {
  
  func demoInlineEditableMenuViewDidPerformEditActionA(_ menuView: DemoInlineEditableMenuView)
  
  func demoInlineEditableMenuViewDidPerformEditActionB(_ menuView: DemoInlineEditableMenuView)

  func demoInlineEditableMenuViewDidPerformEditActionC(_ menuView: DemoInlineEditableMenuView)
  
}

public final class DemoInlineEditableMenuView: UIView {
  
  // MARK: - Properties
  private var isInEditMode = false
  
  private let contentView = UIView()
  
  // MARK: - Init & deinit
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.addSubview(contentView)
    
    updateContentView(animated: false)
    
    let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGestureRecognized(_:)))
    contentView.addGestureRecognizer(longPressGestureRecognizer)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.menuControllerWillHideMenu(_:)), name: UIMenuController.willHideMenuNotification, object: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - UIResponder overrides
  public override var canBecomeFirstResponder: Bool {
    return true
  }
  
  public override func becomeFirstResponder() -> Bool {
    let success = super.becomeFirstResponder()
    
    if success {
      isInEditMode = true
      updateContentView(animated: true)
    }
    
    return success
  }
  
  public override func resignFirstResponder() -> Bool {
    let success = super.resignFirstResponder()
    
    if success {
      isInEditMode = false
      updateContentView(animated: true)
    }
    
    return success
  }
  
  // MARK: - Action handlers
  @objc
  private func longPressGestureRecognized(_ recognizer: UILongPressGestureRecognizer) {
    guard self.becomeFirstResponder() else {
      return
    }
    
    UIMenuController.shared.menuItems = [
      UIMenuItem(title: "Action A", action: #selector(DemoInlineEditableMenuViewEditActions.demoInlineEditableMenuViewEditActionA(_:))),
      UIMenuItem(title: "Action B", action: #selector(DemoInlineEditableMenuViewEditActions.demoInlineEditableMenuViewEditActionB(_:))),
      UIMenuItem(title: "Action C", action: #selector(DemoInlineEditableMenuViewEditActions.demoInlineEditableMenuViewEditActionC(_:))),
    ]
    
    UIMenuController.shared.showMenu(from: self.contentView, rect: self.contentView.bounds)
    
    if !UIMenuController.shared.isMenuVisible {
      // If no menu items is actually displayed, resign first responder.
      _ = self.resignFirstResponder()
    }
  }
  
  // MARK: - Notification handlers
  @objc
  private func menuControllerWillHideMenu(_ notification: Notification) {
    if self.isFirstResponder {
      _ = self.resignFirstResponder()
    }
  }
  
  // MARK: - Helper methods
  private func updateContentView(animated: Bool) {
    let changeBlock: () -> Void
    
    if isInEditMode {
      changeBlock = { self.contentView.backgroundColor = .blue }
    } else {
      changeBlock = { self.contentView.backgroundColor = .gray }
    }
    
    if animated {
      UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: changeBlock, completion: nil)
    } else {
      changeBlock()
    }
  }
}

extension DemoInlineEditableMenuView: DemoInlineEditableMenuViewEditActions {
  
  public func demoInlineEditableMenuViewEditActionA(_ sender: Any) {
    self.searchResponderChain(ofType: DemoInlineEditableMenuViewEditActionHandling.self)?.demoInlineEditableMenuViewDidPerformEditActionA(self)
  }
  
  public func demoInlineEditableMenuViewEditActionB(_ sender: Any) {
    self.searchResponderChain(ofType: DemoInlineEditableMenuViewEditActionHandling.self)?.demoInlineEditableMenuViewDidPerformEditActionB(self)
  }
  
  public func demoInlineEditableMenuViewEditActionC(_ sender: Any) {
    self.searchResponderChain(ofType: DemoInlineEditableMenuViewEditActionHandling.self)?.demoInlineEditableMenuViewDidPerformEditActionC(self)
  }
  
}
