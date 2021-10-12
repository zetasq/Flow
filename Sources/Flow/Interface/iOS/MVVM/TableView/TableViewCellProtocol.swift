//
//  TableViewCellProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/9/2.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

public protocol TableViewCellProtocol: UITableViewCell & ViewModelViewProtocol & TableViewReusableViewSizingProtocol where ViewModel: TableViewCellModelProtocol {
  
}
