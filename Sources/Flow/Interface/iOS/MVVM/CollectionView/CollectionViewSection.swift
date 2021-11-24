//
//  CollectionViewSection.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/4.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation

open class CollectionViewSection {
  
  // MARK: - Properties
  private final var supplementaryViewModelsTable: [String: CollectionViewSupplementaryViewModelProtocol] = [:]
  
  public internal(set) final var viewModels: [CollectionViewCellModelProtocol] = []
  
  internal weak var delegate: CollectionViewSectionDelegate?
  
  // MARK: - Init & deinit
  public init() {}
  
  // MARK: - CollectionView Observer
  internal func _notifyCollectionViewTraitsChange(_ collectionViewTraits: CollectionViewTraits) {
    collectionViewTraitsDidChange(collectionViewTraits)
  }
  
  open func collectionViewTraitsDidChange(_ collectionViewTraits: CollectionViewTraits) {}
  
  // MARK: - Cell Models
  public func replaceWithViewModels(_ newViewModels: [CollectionViewCellModelProtocol], animated: Bool) {
    let change = {
      for viewModel in self.viewModels {
        viewModel.boundCollectionViewSection = nil
      }

      for viewModel in newViewModels {
        viewModel.boundCollectionViewSection = self
      }

      self.viewModels = newViewModels
    }

    if let delegate = delegate {
      delegate.collectionViewSection(self, requestReloadingWholeSectionWithChange: change, animated: animated)
    } else {
      change()
    }
  }

  public final func addViewModels(_ newViewModels: [CollectionViewCellModelProtocol], animated: Bool) {
    let change = {
      for viewModel in newViewModels {
        viewModel.boundCollectionViewSection = self
      }
      
      self.viewModels.append(contentsOf: newViewModels)
    }
    
    if let delegate = delegate {
      delegate.collectionViewSection(self,
                                     requestInsertingAtIndices: Array(viewModels.count..<viewModels.count+newViewModels.count),
                                     dataChange: change,
                                     animated: animated)
    } else {
      change()
    }
  }
  
  public func addViewModel(_ newViewModel: CollectionViewCellModelProtocol, animated: Bool) {
    addViewModels([newViewModel], animated: animated)
  }
  
  // MARK: - SupplementaryView Models
  public final func supplementaryViewModel(ofKind kind: String) -> CollectionViewSupplementaryViewModelProtocol? {
    return supplementaryViewModelsTable[kind]
  }
  
  public final func setSupplementaryViewModel(_ supplementaryViewModel: CollectionViewSupplementaryViewModelProtocol?, ofKind kind: String, animated: Bool) {
    let change = {
      if let oldSupplementaryViewModel = self.supplementaryViewModelsTable.removeValue(forKey: kind) {
        oldSupplementaryViewModel.boundCollectionViewSection = nil
      }
      
      supplementaryViewModel?.boundCollectionViewSection = self
      self.supplementaryViewModelsTable[kind] = supplementaryViewModel
    }
    
    if let delegate = delegate {
      delegate.collectionViewSection(self,
                                     requestUpdatingSupplementaryViewsWithChange: change,
                                     animated: animated)
    } else {
      change()
    }
  }

}

#endif
