//
//  TableViewSectionDelegate.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/9/2.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)
import Foundation
import UIKit

@MainActor
public protocol TableViewSectionDelegate: AnyObject {
  
  func tableViewSection(_ section: TableViewSection,
                        requestReloadingAtIndices rowIndices: [Int],
                        animated: Bool)
  
  func tableViewSection(_ section: TableViewSection,
                        requestReloadingWholeSectionWithChange dataChange: @escaping () -> Void,
                        animated: Bool)
  
  func tableViewSection(_ section: TableViewSection,
                        requestInsertingAtIndices rowIndices: [Int],
                        dataChange: @escaping () -> Void,
                        animated: Bool)
  
  func tableViewSection(_ section: TableViewSection,
                        requestDeletingAtIndices rowIndices: [Int],
                        dataChange: @escaping () -> Void,
                        animated: Bool)
  
  func tableViewSection(_ section: TableViewSection,
                        requestUpdatingHeaderWithChange dataChange: @escaping () -> Void,
                        animated: Bool)
  
  func tableViewSection(_ section: TableViewSection,
                        requestUpdatingFooterWithChange dataChange: @escaping () -> Void,
                        animated: Bool)
  
  func tableViewSection(_ section: TableViewSection,
                        requestSelectingRowAt rowIndex: Int,
                        animated: Bool,
                        scrollPosition: UITableView.ScrollPosition)
  
  func tableViewSection(_ section: TableViewSection,
                        requestDeselectingRowAt rowIndex: Int,
                        animated: Bool)
  
  func tableViewSection(_ section: TableViewSection,
                        requestScrollingToRowAt rowIndex: Int,
                        scrollPosition: UITableView.ScrollPosition,
                        animated: Bool)
  
  func tableViewSection(_ section: TableViewSection,
                        requestUpdatingTableViewLayoutAnimated animated: Bool)
  
}

#endif
