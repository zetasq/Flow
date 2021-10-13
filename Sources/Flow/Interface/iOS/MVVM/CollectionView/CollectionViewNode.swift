//
//  CollectionViewNode.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/4.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

public final class CollectionViewNode<CollectionViewType: UICollectionView, LayoutType: UICollectionViewLayout & CollectionViewLayoutProtocol>: NSObject, ViewModelViewMappable, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  // MARK: - Properties
  public let collectionView: CollectionViewType
  
  public private(set) var layout: LayoutType
  
  public private(set) var viewModelSections: [LayoutType.ViewModelSectionType] = []
  
  private lazy var reorderGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self._collectionViewNode_reorderGestureRecognized(_:)))
  
  // MARK: - Init & deinit
  public init(frame: CGRect) {
    _ = UICollectionViewLayout.swizzleToken
    
    self.layout = LayoutType()
    
    self.collectionView = CollectionViewType(frame: frame, collectionViewLayout: self.layout)
    
    super.init()
    
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    // When we call reloadData on the collectionView for the first time, the dataSource methods will not called (strange!). But we still keep it.
    self.collectionView.reloadData()
  }
  
  // MARK: - Objc Runtime
  public override func responds(to aSelector: Selector!) -> Bool {
    if aSelector == #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)) {
      assert(LayoutType.self is UICollectionViewFlowLayout.Type)
      let flowLayout = layout as! UICollectionViewFlowLayout
      
      // If the flowLayout has non-zero estimatedItemSize, we shouldn't let flowLayout call collectionView(_:layout:sizeForItemAt:)
      return flowLayout.estimatedItemSize == .zero
    }
    
    return super.responds(to: aSelector)
  }
  
  // MARK: - Reorder Gesture
  public func activateReorderGestureRecognizer() {
    collectionView.addGestureRecognizer(reorderGestureRecognizer)
  }
  
  public func deactivateReorderGestureRecognizer() {
    collectionView.removeGestureRecognizer(reorderGestureRecognizer)
  }
  
  @objc
  private func _collectionViewNode_reorderGestureRecognized(_ recognizer: UILongPressGestureRecognizer) {
    switch recognizer.state {
    case .began:
      guard let selectedIndexPath = collectionView.indexPathForItem(at: recognizer.location(in: collectionView)) else {
        recognizer.isEnabled = false
        recognizer.isEnabled = true
        break
      }
      
      collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
    case .changed:
      collectionView.updateInteractiveMovementTargetPosition(recognizer.location(in: collectionView))
    case .ended:
      collectionView.updateInteractiveMovementTargetPosition(recognizer.location(in: collectionView))
      collectionView.endInteractiveMovement()
    case .cancelled:
      collectionView.cancelInteractiveMovement()
    default:
      break
    }
  }
  
  // MARK: - UICollectionViewDataSource
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return viewModelSections.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModelSections[section].viewModels.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    let viewModelClass = type(of: viewModel)
    guard let viewClass = _mvvm_registeredViewClassInMapping(forViewModelClass: viewModelClass) else {
      fatalError("Cannot find paired view class for viewModel: \(viewModel)")
    }
    
    let cell = collectionView.dequeueOpaqueReusableCell(type: viewClass.self, for: indexPath)
    
    cell._associatedViewModel = viewModel
    
    return cell
  }
  
  public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let viewModelSection = viewModelSections[indexPath.section]
    guard let supplementaryViewModel = viewModelSection.supplementaryViewModel(ofKind: kind) else {
      assert(false, "Unexpected supplementary view request of kind \(kind) at indexPath: \(indexPath)")
      return UICollectionReusableView()
    }
    
    let viewModelClass = type(of: supplementaryViewModel)
    guard let viewClass = _mvvm_registeredViewClassInMapping(forViewModelClass: viewModelClass) else {
      fatalError("Cannot find paired view class for supplementaryViewModel: \(supplementaryViewModel)")
    }
    
    let supplementaryView = collectionView.dequeueOpaqueReusableSupplementaryView(type: viewClass.self, ofKind: kind, for: indexPath)
    
    supplementaryView._associatedViewModel = supplementaryViewModel
    
    return supplementaryView
  }
  
  public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.item]
    
    return viewModel.canMove
  }
  
  public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard sourceIndexPath != destinationIndexPath else { return }
    
    collectionView.deselectItem(at: destinationIndexPath, animated: true)
    
    let sourceSection = viewModelSections[sourceIndexPath.section]
    let viewModel = sourceSection.viewModels.remove(at: sourceIndexPath.item)
    
    let destinationSection = viewModelSections[destinationIndexPath.section]
    destinationSection.viewModels.insert(viewModel, at: destinationIndexPath.item)
    
    viewModel.boundCollectionViewSection = destinationSection
  }
  
  // MARK: - UICollectionViewDelegate
  public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    return viewModel.shouldHighlight
  }
  
  public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.row]
    
    return viewModel.shouldSelect
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.item]
    
    if viewModel.autoDeselect {
      collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    if let selectHandler = viewModel.selectHandler {
      let cell = collectionView.cellForItem(at: indexPath)!
      selectHandler(viewModel, cell)
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
    guard originalIndexPath.section == proposedIndexPath.section else {
      // Prevent dragging outside current section, otherwise it's really hard to maintain the datasource (the app would crash due to out-of-bounds index)
      return originalIndexPath
    }
    
    let viewModelSection = viewModelSections[proposedIndexPath.section]
    let viewModel = viewModelSection.viewModels[proposedIndexPath.item]
    
    return viewModel.canBeMovedTo ? proposedIndexPath : originalIndexPath
  }
  
  public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.item]
    
    return viewModel.supportedMenuActions.contains(action)
  }
  
  public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    let viewModelSection = viewModelSections[indexPath.section]
    let viewModel = viewModelSection.viewModels[indexPath.item]
    
    if let menuActionHandler = viewModel.menuActionHandler {
      let cell = collectionView.cellForItem(at: indexPath)!
      menuActionHandler(viewModel, action, cell)
    }
  }
  
  // MARK: - UICollectionViewDelegateFlowLayout
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    assert(LayoutType.self is UICollectionViewFlowLayout.Type)
    
    let flowLayout = layout as! UICollectionViewFlowLayout
    
    let viewModelSection = viewModelSections[indexPath.section] as! CollectionViewFlowLayoutSection
    let viewModel = viewModelSection.viewModels[indexPath.item]
    
    let viewModelClass = type(of: viewModel)
    guard let viewClass = _mvvm_registeredViewClassInMapping(forViewModelClass: viewModelClass) else {
      fatalError("Cannot find paired view class for viewModel: \(viewModel)")
    }
    
    guard let viewSizingClass = viewClass as? CollectionViewCellSizingProtocol.Type else {
      fatalError("\(viewClass) does not conform to \(CollectionViewCellSizingProtocol.self)")
    }
    
    let cellSize = viewSizingClass.cellSize
    
    switch cellSize {
    case .dynamic:
      fatalError("The UICollectionViewFlowLayout object has non-zero estimatedItemSize")
    case .manual(let layoutValue):
      switch layoutValue {
      case .inheritFromSection:
        switch viewModelSection.spacing.itemSize {
        case .inheritFromLayout:
          return flowLayout.itemSize
        case .fixed(let value):
          return value
        }
      case .fixed(let value):
        return value
      }
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    assert(LayoutType.self is UICollectionViewFlowLayout.Type)
    
    let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

    let layoutValue = (viewModelSections[section] as! CollectionViewFlowLayoutSection).spacing.sectionInset
    
    switch layoutValue {
    case .inheritFromLayout:
      return flowLayout.sectionInset
    case .fixed(let value):
      return value
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    assert(LayoutType.self is UICollectionViewFlowLayout.Type)
    
    let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

    let layoutValue = (viewModelSections[section] as! CollectionViewFlowLayoutSection).spacing.minimumLineSpacing
    
    switch layoutValue {
    case .inheritFromLayout:
      return flowLayout.minimumLineSpacing
    case .fixed(let value):
      return value
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    assert(LayoutType.self is UICollectionViewFlowLayout.Type)
    
    let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

    let layoutValue = (viewModelSections[section] as! CollectionViewFlowLayoutSection).spacing.minimumInteritemSpacing
    
    switch layoutValue {
    case .inheritFromLayout:
      return flowLayout.minimumInteritemSpacing
    case .fixed(let value):
      return value
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    assert(LayoutType.self is UICollectionViewFlowLayout.Type)
    let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

    let viewModelSection = viewModelSections[section] as! CollectionViewFlowLayoutSection
    
    guard let sectionHeaderViewModel = viewModelSection.sectionHeaderViewModel else {
      return .zero
    }
    
    let viewModelClass = type(of: sectionHeaderViewModel)
    guard let viewClass = _mvvm_registeredViewClassInMapping(forViewModelClass: viewModelClass) else {
      fatalError("Cannot find paired view class for sectionHeaderViewModel: \(sectionHeaderViewModel)")
    }
    
    guard let viewSizingClass = viewClass as? CollectionViewSupplementaryViewSizingProtocol.Type else {
      fatalError("\(viewClass) does not conform to \(CollectionViewSupplementaryViewSizingProtocol.self)")
    }
    
    let layoutValue = viewSizingClass.collectionViewSupplementaryViewReferenceSize(forCollectionViewBounds: collectionView.bounds)
    
    switch layoutValue {
    case .inheritFromSection:
      switch viewModelSection.spacing.headerReferenceSize {
      case .inheritFromLayout:
        return flowLayout.headerReferenceSize
      case .fixed(let value):
        return value
      }
    case .fixed(let value):
      return value
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    assert(LayoutType.self is UICollectionViewFlowLayout.Type)
    let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

    let viewModelSection = viewModelSections[section] as! CollectionViewFlowLayoutSection

    guard let sectionFooterViewModel = viewModelSection.sectionFooterViewModel else {
      return .zero
    }
    
    let viewModelClass = type(of: sectionFooterViewModel)
    guard let viewClass = _mvvm_registeredViewClassInMapping(forViewModelClass: viewModelClass) else {
      fatalError("Cannot find paired view class for sectionFooterViewModel: \(sectionFooterViewModel)")
    }
    
    guard let viewSizingClass = viewClass as? CollectionViewSupplementaryViewSizingProtocol.Type else {
      fatalError("\(viewClass) does not conform to \(CollectionViewSupplementaryViewSizingProtocol.self)")
    }
    
    let layoutValue = viewSizingClass.collectionViewSupplementaryViewReferenceSize(forCollectionViewBounds: collectionView.bounds)
    
    switch layoutValue {
    case .inheritFromSection:
      switch viewModelSection.spacing.footerReferenceSize {
      case .inheritFromLayout:
        return flowLayout.footerReferenceSize
      case .fixed(let value):
        return value
      }
    case .fixed(let value):
      return value
    }
  }

}

// MARK: - CollectionViewSectionDelegate
extension CollectionViewNode: CollectionViewSectionDelegate {
  public func collectionViewSection(_ section: CollectionViewSection,
                                    requestReloadingWholeSectionWithChange dataChange: @escaping () -> Void,
                                    animated: Bool) {
    let updateBlock = {
      self.collectionView.performBatchUpdates({
        guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
          fatalError("Cannot find section:\(section) before reloading section")
        }

        dataChange()

        self.collectionView.reloadSections(IndexSet(integer: sectionIndex))
      }, completion: nil)
    }

    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
  public func collectionViewSection(_ section: CollectionViewSection, requestInsertingAtIndices itemIndices: [Int], dataChange: @escaping () -> Void, animated: Bool) {
    let updateBlock = {
      self.collectionView.performBatchUpdates({
        guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
          fatalError("Cannot find section:\(section) before inserting indices at \(itemIndices)")
        }
        
        dataChange()
        
        let indexPaths = itemIndices.map { IndexPath(row: $0, section: sectionIndex) }
        self.collectionView.insertItems(at: indexPaths)
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
  public func collectionViewSection(_ section: CollectionViewSection, requestUpdatingSupplementaryViewsWithChange dataChange: @escaping () -> Void, animated: Bool) {
    let updateBlock = {
      self.collectionView.performBatchUpdates({
        guard let sectionIndex = self.viewModelSections.firstIndex(where: { $0 === section }) else {
          fatalError("Cannot find section:\(section) before updating supplementary views")
        }
        
        dataChange()
        
        self.collectionView.reloadSections(IndexSet(integer: sectionIndex))
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
}

// MARK: - CollectionViewLayoutAugmentDelegate
extension CollectionViewNode: CollectionViewLayoutAugmentDelegate {
  
  public func collectionViewLayoutDidPrepare(_ layout: UICollectionViewLayout) {
    guard let bounds = layout.collectionView?.bounds else { return }
    
    let traits = CollectionViewTraits(bounds: bounds)
    
    for viewModelSection in viewModelSections {
      viewModelSection._notifyCollectionViewTraitsChange(traits)
    }
  }
  
}

// MARK: - Public - Register ViewModel
extension CollectionViewNode {
  
  public func registerClassForCell<T: CollectionViewCellProtocol>(_ viewClass: T.Type) {
    _mvvm_registerViewClassToMapping(viewClass)
    collectionView.registerClassForCell(type: viewClass)
  }
  
  public func registerClassForSupplementaryView<T: CollectionViewSupplementaryViewProtocol>(_ supplementaryViewClass: T.Type, ofKind kind: String) {
    _mvvm_registerViewClassToMapping(supplementaryViewClass)
    collectionView.registerClassForSupplementaryView(type: supplementaryViewClass, ofKind: kind)
  }
  
  public func registerClassForHeaderView<T: CollectionViewSupplementaryViewProtocol>(_ headerViewClass: T.Type) {
    registerClassForSupplementaryView(headerViewClass, ofKind: UICollectionView.elementKindSectionHeader)
  }
  
  public func registerClassForFooterView<T: CollectionViewSupplementaryViewProtocol>(_ footerViewClass: T.Type) {
    registerClassForSupplementaryView(footerViewClass, ofKind: UICollectionView.elementKindSectionFooter)
  }
  
}

// MARK: - Public - Sizing Strategy
extension CollectionViewNode where LayoutType: UICollectionViewFlowLayout {

  public func setCellSizingPolicy(_ cellSizingPolicy: UICollectionViewLayout.CellSizingPolicy) {
    switch cellSizingPolicy {
    case .dynamic:
      layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    case .manual(let itemSize):
      layout.estimatedItemSize = .zero
      layout.itemSize = itemSize
    }
  }
  
}

// MARK: - Public - Load
extension CollectionViewNode {

  public func reloadContent() {
    // TODO: Add loader support
    collectionView.reloadData()
  }
  
}

// MARK: - Public - ViewModelSection
extension CollectionViewNode {
  public func addViewModelSection(_ section: LayoutType.ViewModelSectionType, animated: Bool) {
    addViewModelSections([section], animated: animated)
  }
  
  public func addViewModelSections(_ sections: [LayoutType.ViewModelSectionType], animated: Bool) {
    let updateBlock = {
      self.collectionView.performBatchUpdates({
        let indices = IndexSet(integersIn: self.viewModelSections.count..<self.viewModelSections.count + sections.count)
        
        self.viewModelSections.append(contentsOf: sections)
        
        for section in sections {
          section.delegate = self
        }
        
        self.collectionView.insertSections(indices)
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
  public func removeSection(_ section: LayoutType.ViewModelSectionType, animated: Bool) {
    removeSections([section], animated: animated)
  }
  
  public func removeSections(_ sections: [LayoutType.ViewModelSectionType], animated: Bool) {
    let updateBlock = {
      self.collectionView.performBatchUpdates({
        var indicesToDelete = IndexSet()
        
        for section in sections {
          guard let index = self.viewModelSections.firstIndex(where: { $0 === section }) else {
            continue
          }
          
          indicesToDelete.insert(index)
        }
        
        for section in sections {
          guard let index = self.viewModelSections.firstIndex(where: { $0 === section }) else {
            continue
          }
          
          section.delegate = nil
          self.viewModelSections.remove(at: index)
        }
        
        self.collectionView.deleteSections(indicesToDelete)
      }, completion: nil)
    }
    
    if animated {
      updateBlock()
    } else {
      UIView.performWithoutAnimation {
        updateBlock()
      }
    }
  }
  
}

// MARK: - Public - Utility Methods
extension CollectionViewNode {

  // TODO: like UIView's insert/bring methods, we can use tableView's insert and move methods to do the same things
  public func deselectAllItems(animated: Bool) {
    collectionView.selectItem(at: nil, animated: animated, scrollPosition: [])
  }
  
}

#endif
