//
//  UIView+StyleAutomation.swift
//  
//
//  Created by Zhu Shengqi on 2021/3/17.
//

#if os(iOS)

import Foundation
import UIKit
import FlowObjC

extension UIView {
	public final func setupStyleAutomation() {
		UIView.flow_addViewDidMoveToWindowHandler { view in
			view.applyStyleRules()
		}

		#if DEBUG
		DebugStyleAutomationSetupFlag = true
		#endif
	}
}

#endif
