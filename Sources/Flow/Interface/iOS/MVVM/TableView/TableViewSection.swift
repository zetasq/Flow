//
//  ViewModelSection.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/7/15.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

@MainActor
public final class TableViewSection {
  
  // MARK: - Properties
  
  public internal(set) var viewModels: [TableViewCellModelProtocol] = []
  
  public private(set) var headerViewModel: TableViewHeaderFooterViewModelProtocol?
  
  public private(set) var footerViewModel: TableViewHeaderFooterViewModelProtocol?
  
  internal weak var delegate: TableViewSectionDelegate?
  
  // MARK: - Init & deinit
  
  public init() {}
  
  // MARK: - Cell ViewModels
  public func reloadViewModels(_ viewModels: [TableViewCellModelProtocol], animated: Bool) {
    let indices = viewModels.compactMap { (viewModel) -> Int? in
      return self.viewModels.firstIndex(where: { $0 === viewModel })
    }
    
    delegate?.tableViewSection(self, requestReloadingAtIndices: indices, animated: animated)
  }
  
  public func reloadViewModel(_ viewModel: TableViewCellModelProtocol, animated: Bool) {
    reloadViewModels([viewModel], animated: animated)
  }
  
  public func replaceWithViewModels(_ newViewModels: [TableViewCellModelProtocol], animated: Bool) {
    let change = {
      for viewModel in self.viewModels {
        viewModel.boundTableViewSection = nil
      }
      
      for viewModel in newViewModels {
        viewModel.boundTableViewSection = self
      }
      
      self.viewModels = newViewModels
    }
    
    if let delegate = delegate {
      delegate.tableViewSection(self, requestReloadingWholeSectionWithChange: change, animated: animated)
    } else {
      change()
    }
  }
  
  public func addViewModels(_ newViewModels: [TableViewCellModelProtocol], animated: Bool) {
    let change = {
      for viewModel in newViewModels {
        viewModel.boundTableViewSection = self
      }
      
      self.viewModels.append(contentsOf: newViewModels)
    }
    
    if let delegate = delegate {
      delegate.tableViewSection(self,
                                 requestInsertingAtIndices: Array(viewModels.count..<viewModels.count+newViewModels.count),
                                 dataChange: change,
                                 animated: animated)
    } else {
      change()
    }
  }
  
  public func addViewModel(_ newViewModel: TableViewCellModelProtocol, animated: Bool) {
    addViewModels([newViewModel], animated: animated)
  }
  
  public func insertViewModel(_ newViewModel: TableViewCellModelProtocol, at index: Int, animated: Bool) {
    let change = {
      newViewModel.boundTableViewSection = self
      self.viewModels.insert(newViewModel, at: index)
    }
    
    if let delegate = delegate {
      delegate.tableViewSection(self,
                                 requestInsertingAtIndices: [index],
                                 dataChange: change,
                                 animated: animated)
    } else {
      change()
    }
  }
  
  public func removeViewModel(_ viewModel: TableViewCellModelProtocol, animated: Bool) {
    removeViewModels([viewModel], animated: animated)
  }
  
  public func removeViewModels(_ viewModels: [TableViewCellModelProtocol], animated: Bool) {
    let indicesToRemove = viewModels.compactMap { (viewModel) -> Int? in
      return self.viewModels.firstIndex(where: { $0 === viewModel})
      }.sorted(by: >)
    
    let change = {
      for index in indicesToRemove {
        let viewModel = self.viewModels.remove(at: index)
        viewModel.boundTableViewSection = nil
      }
    }
    
    if let delegate = delegate {
      delegate.tableViewSection(self,
                                 requestDeletingAtIndices: indicesToRemove,
                                 dataChange: change,
                                 animated: animated)
    } else {
      change()
    }
  }
  
  public func removeAllViewModels(animated: Bool) {
    let change = {
      for viewModel in self.viewModels {
        viewModel.boundTableViewSection = nil
      }
      self.viewModels.removeAll()
    }
    
    if let delegate = delegate {
      delegate.tableViewSection(self,
                                 requestInsertingAtIndices: Array(0..<viewModels.count),
                                 dataChange: change,
                                 animated: animated)

    } else {
      change()
    }
  }
  
  public func selectViewModel(_ viewModel: TableViewCellModelProtocol, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
    guard let index = viewModels.firstIndex(where: { $0 === viewModel }) else {
      return
    }
    
    delegate?.tableViewSection(self,
                               requestSelectingRowAt: index,
                               animated: animated,
                               scrollPosition: scrollPosition)
  }
  
  public func deselectViewModel(_ viewModel: TableViewCellModelProtocol, animated: Bool) {
    guard let index = viewModels.firstIndex(where: { $0 === viewModel }) else {
      return
    }
    
    delegate?.tableViewSection(self,
                               requestDeselectingRowAt: index,
                               animated: animated)
  }
  
  public func scrollToViewModel(_ viewModel: TableViewCellModelProtocol, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
    guard let index = viewModels.firstIndex(where: { $0 === viewModel }) else {
      return
    }
    
    delegate?.tableViewSection(self,
                               requestScrollingToRowAt: index,
                               scrollPosition: scrollPosition,
                               animated: animated)
  }
  
  // MARK: - Header/Footer ViewModels
  public func updateHeaderViewModel(_ headerViewModel: TableViewHeaderFooterViewModelProtocol?, animated: Bool) {
    let change = {
      self.headerViewModel?.boundTableViewSection = nil
      headerViewModel?.boundTableViewSection = self
      self.headerViewModel = headerViewModel
    }
    
    if let delegate = delegate {
      delegate.tableViewSection(self, requestUpdatingHeaderWithChange: change, animated: animated)
    } else {
      change()
    }
  }
  
  public func updateFooterViewModel(_ footerViewModel: TableViewHeaderFooterViewModelProtocol?, animated: Bool) {
    let change = {
      self.footerViewModel?.boundTableViewSection = nil
      footerViewModel?.boundTableViewSection = self
      self.footerViewModel = footerViewModel
    }
    
    if let delegate = delegate {
      delegate.tableViewSection(self, requestUpdatingFooterWithChange: change, animated: animated)
    } else {
      change()
    }
  }
  
  // MARK: Common
  public func updateLayout(for viewModel: TableViewReusableViewModelProtocol, animated: Bool) {
    delegate?.tableViewSection(self, requestUpdatingTableViewLayoutAnimated: animated)
  }
  
}

#endif
