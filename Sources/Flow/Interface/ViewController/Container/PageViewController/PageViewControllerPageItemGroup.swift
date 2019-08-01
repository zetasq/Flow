//
//  PageViewControllerPageItemGroup.swift
//  
//
//  Created by Zhu Shengqi on 2019/7/30.
//

import Foundation
import UIKit

protocol PageViewControllerPageItemGroupDelegate: AnyObject {
  
}

public final class PageViewControllerPageItemGroup<ItemMetaData, ItemViewController: UIViewController> {
  
  public typealias ItemType = PageViewControllerPageItem<ItemMetaData, ItemViewController>
  
  internal weak var delegate: PageViewControllerPageItemGroupDelegate?
  
  internal private(set) var items: [ItemType]
  
  public init(items: [ItemType] = []) {
    self.items = items
  }
  
//  public func addItem(_ item: ItemType) {
//
//  }
  
}
