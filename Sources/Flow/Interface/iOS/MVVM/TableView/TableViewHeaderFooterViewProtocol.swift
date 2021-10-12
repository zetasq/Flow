//
//  TableViewHeaderFooterViewProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/9/2.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import UIKit

public protocol TableViewHeaderFooterViewProtocol: UITableViewHeaderFooterView & ViewModelViewProtocol & TableViewReusableViewSizingProtocol where ViewModel: TableViewHeaderFooterViewModelProtocol {}

#endif
