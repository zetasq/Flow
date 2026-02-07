//
//  DemoInlineEditableMenuView.swift
//  
//
//  Created by Zhu Shengqi on 2019/12/19.
//

#if os(iOS)

import Foundation
import UIKit

#if DEBUG

@MainActor
public protocol DemoInlineEditableMenuViewEditActionHandling {
  
  func demoInlineEditableMenuViewDidPerformEditActionA(_ menuView: DemoInlineEditableMenuView)
  
  func demoInlineEditableMenuViewDidPerformEditActionB(_ menuView: DemoInlineEditableMenuView)

  func demoInlineEditableMenuViewDidPerformEditActionC(_ menuView: DemoInlineEditableMenuView)
  
}

public final class DemoInlineEditableMenuView: UIView {
  
  // MARK: - Properties
  
  private let contentView = UIView()
  
  // MARK: - Init & deinit
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.addSubview(contentView)
    
    editMenuInteraction = UIEditMenuInteraction(delegate: self)
    contentView.addInteraction(editMenuInteraction!)
    
    // Create the gesture recognizer.
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(_:)))
    longPress.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
    contentView.addGestureRecognizer(longPress)
    
    updateContentViewForEditMenuStatus()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var editMenuInteraction: UIEditMenuInteraction?
  
  private var isShowingEditMenu = false {
    didSet {
      updateContentViewForEditMenuStatus()
    }
  }
  
  private func updateContentViewForEditMenuStatus() {
    if isShowingEditMenu {
      contentView.backgroundColor = .blue
    } else {
      contentView.backgroundColor = .gray
    }
  }
  
  // MARK: - Action handlers
  @objc
  private func longPressGestureRecognized(_ recognizer: UILongPressGestureRecognizer) {
    guard recognizer.state == .began else { return }
    
    let location = recognizer.location(in: self.contentView)
    let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
    
    if let interaction = editMenuInteraction {
      interaction.presentEditMenu(with: configuration)
    }
  }
}

extension DemoInlineEditableMenuView: @MainActor UIEditMenuInteractionDelegate {
  public func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
    let additionalActions: [UIMenuElement] = [
      UIAction(title: "Action A", handler: { [weak self] action in
        guard let self else { return }
        
        self.searchResponderChain(ofType: DemoInlineEditableMenuViewEditActionHandling.self)?.demoInlineEditableMenuViewDidPerformEditActionA(self)
      }),
      UIAction(title: "Action B", handler: { [weak self] action in
        guard let self else { return }
        
        self.searchResponderChain(ofType: DemoInlineEditableMenuViewEditActionHandling.self)?.demoInlineEditableMenuViewDidPerformEditActionB(self)
      }),
      UIAction(title: "Action C", handler: { [weak self] action in
        guard let self else { return }
        
        self.searchResponderChain(ofType: DemoInlineEditableMenuViewEditActionHandling.self)?.demoInlineEditableMenuViewDidPerformEditActionC(self)
      })
    ]
    
    return UIMenu(children: suggestedActions + additionalActions)
  }
  
  public func editMenuInteraction(_ interaction: UIEditMenuInteraction, willPresentMenuFor configuration: UIEditMenuConfiguration, animator: any UIEditMenuInteractionAnimating) {
    animator.addAnimations {
      self.isShowingEditMenu = true
    }
  }
  
  public func editMenuInteraction(_ interaction: UIEditMenuInteraction, willDismissMenuFor configuration: UIEditMenuConfiguration, animator: any UIEditMenuInteractionAnimating) {
    self.isShowingEditMenu = false
  }
}


#endif

#endif
