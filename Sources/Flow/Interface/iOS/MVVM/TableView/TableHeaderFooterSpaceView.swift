//
//  SpaceHeaderFooterView.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/9/1.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import UIKit

public final class TableHeaderFooterSpaceView: UITableViewHeaderFooterView, TableViewHeaderFooterViewProtocol {
  
  public typealias ViewModel = TableHeaderFooterSpaceViewModel
  
  public static func tableViewReusableViewHeight(forTableViewBounds tableViewBounds: CGRect) -> TableViewReusableViewHeight {
    return .dynamic
  }
  
  private var heightConstraint: NSLayoutConstraint?
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    
    setupUI()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    let backgroundView = UIView(frame: self.bounds)
    backgroundView.backgroundColor = .clear
    self.backgroundView = backgroundView
    
    let dummyView = UIView()
    contentView.addSubview(dummyView)
    dummyView.translatesAutoresizingMaskIntoConstraints = false

    self.heightConstraint = dummyView.heightAnchor.constraint(equalToConstant: 0)
    self.heightConstraint?.priority = .defaultHigh

    NSLayoutConstraint.activate([
      dummyView.topAnchor.constraint(equalTo: contentView.topAnchor),
      dummyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      dummyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      dummyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      self.heightConstraint!
    ])
  }
  
  public func viewModelDidUpdate() {
    guard let viewModel = self.viewModel else {
      return
    }
    
    self.heightConstraint!.constant = viewModel.height
  }
  
}

public final class TableHeaderFooterSpaceViewModel: TableViewHeaderFooterViewModelProtocol {
  
  public let height: CGFloat

  public init(height: CGFloat) {
    self.height = height
  }
  
}

#endif
