//
//  CollectionViewSupplementaryViewProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/11.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation

public protocol CollectionViewSupplementaryViewProtocol: CollectionViewReusableViewProtocol & CollectionViewSupplementaryViewSizingProtocol where ViewModel: CollectionViewSupplementaryViewModelProtocol {
  
}

#endif
