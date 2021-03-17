//
//  UIView+Stylable.swift
//  
//
//  Created by Zhu Shengqi on 2021/3/17.
//

import Foundation

extension PlatformAgnosticView: Stylable {
	public var needsApplyStyleRulesRecursivelyImmediatelyForRulesChange: Bool {
		return self.window != nil
	}

	public var parentStylable: Stylable? {
		return superview
	}

	public var childStylables: [Stylable] {
		return subviews
	}
}
