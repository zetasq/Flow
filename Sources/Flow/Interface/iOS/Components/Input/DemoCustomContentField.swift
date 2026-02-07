//
//  DemoCustomContentField.swift
//  
//
//  Created by Zhu Shengqi on 2020/12/28.
//

#if os(iOS)

import Foundation
import UIKit

#if DEBUG

public final class DemoInputView: UIInputView {
  public override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
    super.init(frame: frame, inputViewStyle: inputViewStyle)
    
    let contentView = UIView()
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.backgroundColor = .green
    
    self.addSubview(contentView)
    AutoLayout {
      contentView.anchor.top == self.anchor.top
      contentView.anchor.leading == self.anchor.leading
      contentView.anchor.bottom == self.anchor.bottom
      contentView.anchor.trailing == self.anchor.trailing
      (contentView.anchor.height == 200).priority(.defaultHigh).store(in: &heightConstraint)
    }
    
    self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.allowsSelfSizing = true
    
    let button = UIButton(type: .system)
    button.setTitle("Change height", for: .normal)
    button.addTarget(self, action: #selector(heightButtonTapped(sender:)), for: .primaryActionTriggered)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(button)
    AutoLayout {
      button.anchor.centerX == contentView.anchor.centerX
      button.anchor.centerY == contentView.anchor.centerY
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var heightConstraint: NSLayoutConstraint?
  
  @objc
  private func heightButtonTapped(sender: Any) {
    UIView.animate(withDuration: 0.25, delay: 0, options: .flushUpdates) {
      if self.heightConstraint?.constant == 200 {
        self.heightConstraint?.constant = 100
      } else {
        self.heightConstraint?.constant = 200
      }
    }
  }
}

public final class DemoCustomContentField: UIControl {
  
  // MARK: - Properties
  private let contentView = UIView()
  
  // MARK: - Init & deinit
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    contentView.isUserInteractionEnabled = false
    self.addSubview(contentView)
    
    updateContentView(animated: false)
    
    self.inputView = DemoInputView()
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
      updateContentView(animated: true)
    }
    
    return success
  }
  
  public override func resignFirstResponder() -> Bool {
    let success = super.resignFirstResponder()
    
    if success {
      updateContentView(animated: true)
    }
    
    return success
  }
  
  private var _inputView: UIView?
  public override var inputView: UIView? {
    get {
      return _inputView
    }
    set {
      _inputView = newValue
    }
  }
  
  public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    super.endTracking(touch, with: event)
    
    guard let touch = touch else { return }
    
    let touchLocation = touch.location(in: self)
    guard self.bounds.contains(touchLocation) else { return }
    
    if !self.isFirstResponder {
      _ = self.becomeFirstResponder()
    }
    
    self.sendActions(for: .touchUpInside)
  }

  // MARK: - Helper methods
  private func updateContentView(animated: Bool) {
    let changeBlock: () -> Void
    
    if self.isFirstResponder {
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

#endif

#endif
