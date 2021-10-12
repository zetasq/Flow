//
//  CollectionViewReusableViewProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/7.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import UIKit

public protocol CollectionViewReusableViewProtocol: UICollectionReusableView & ViewModelViewProtocol where ViewModel: CollectionViewReusableViewModelProtocol {
  
  
}

#endif
