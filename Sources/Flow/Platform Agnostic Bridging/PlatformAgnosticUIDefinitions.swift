//
//  File.swift
//  
//
//  Created by Zhu Shengqi on 2021/3/17.
//

import Foundation

#if os(iOS)

import UIKit

public typealias PlatformAgnosticResponder = UIResponder

extension PlatformAgnosticResponder {
	public var nextPlatformAgnosticResponder: PlatformAgnosticResponder? {
		self.next
	}
}

public typealias PlatformAgnosticView = UIView

public typealias PlatformAgnosticLayoutGuide = UILayoutGuide

public typealias PlatformAgnosticLayoutPriority = UILayoutPriority

#elseif os(macOS)

import AppKit

public typealias PlatformAgnosticResponder = NSResponder

extension PlatformAgnosticResponder {
	public var nextPlatformAgnosticResponder: NSResponder? {
		self.nextResponder
	}
}

public typealias PlatformAgnosticView = NSView

public typealias PlatformAgnosticLayoutGuide = NSLayoutGuide

public typealias PlatformAgnosticLayoutPriority = NSLayoutConstraint.Priority

#endif
