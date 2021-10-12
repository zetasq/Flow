//
//  CollectionViewCellProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/5.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

public protocol CollectionViewCellProtocol: UICollectionViewCell & CollectionViewCellSizingProtocol & CollectionViewReusableViewProtocol where ViewModel: CollectionViewCellModelProtocol {
  
}

#endif
