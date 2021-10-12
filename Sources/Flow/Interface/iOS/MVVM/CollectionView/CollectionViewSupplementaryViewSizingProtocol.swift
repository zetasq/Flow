//
//  CollectionViewSupplementaryViewSizingProtocol.swift
//  Arsenal
//
//  Created by Zhu Shengqi on 2018/10/11.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

public protocol CollectionViewSupplementaryViewSizingProtocol {
  
  static func collectionViewSupplementaryViewReferenceSize(forCollectionViewBounds collectionViewBounds: CGRect) -> CollectionViewReusableViewLayoutValue<CGSize>
  
}

#endif
