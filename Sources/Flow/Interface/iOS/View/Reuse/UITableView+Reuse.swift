//
//  UITableView+Reuse.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 17/03/2017.
//  Copyright © 2017 Zhu Shengqi. All rights reserved.
//

import UIKit

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}

public extension UITableView {
  // MARK: - Register
  func registerClassForCell<T: UITableViewCell>(type: T.Type) {
    register(type, forCellReuseIdentifier: T.reuseIdentifier)
  }
  
  func registerClassForHeaderFooterView<T: UITableViewHeaderFooterView>(type: T.Type) {
    register(type, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
  }
  
  // MARK: - Dequeue
  func dequeueReusableCell<T: UITableViewCell>(type: T.Type, for indexPath: IndexPath) -> T {
    return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
  }
  
  func dequeueOpaqueReusableCell(type: AnyClass, for indexPath: IndexPath) -> UITableViewCell {
    return dequeueReusableCell(withIdentifier: (type as! UITableViewCell.Type).reuseIdentifier, for: indexPath)
  }
  
  func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(type: T.Type) -> T {
    return dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
  }
  
  func dequeueOpaqueReusableHeaderFooterView(type: AnyClass) -> UITableViewHeaderFooterView {
    return dequeueReusableHeaderFooterView(withIdentifier: (type as! UITableViewHeaderFooterView.Type).reuseIdentifier)!
  }
}
