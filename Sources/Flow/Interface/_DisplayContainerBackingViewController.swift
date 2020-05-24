//
//  _DisplayContainerBackingViewController.swift
//  
//
//  Created by Zhu Shengqi on 2020/2/10.
//

import Foundation
import UIKit

internal protocol _DisplayContainerBackingViewControllerDelegate: AnyObject {
  
  func createRootViewForBackingViewController() -> UIView
  
}

internal final class _DisplayContainerBackingViewController: UIViewController {
  
  // MARK: - Properties
  internal weak var delegate: _DisplayContainerBackingViewControllerDelegate?
  
  override func loadView() {
    self.view = self.delegate!.createRootViewForBackingViewController()
  }
  
}
