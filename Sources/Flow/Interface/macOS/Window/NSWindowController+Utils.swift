//
//  NSWindowController+Utils.swift
//  
//
//  Created by Zhu Shengqi on 2021/3/21.
//

#if os(macOS)

import Foundation
import AppKit

extension NSWindowController {
	/// NSWindowController subclasses must override **windowNibName** to create window programmatically. See http://www.openradar.appspot.com/19289232
	public static let dummyNibNameForProgrammaticallyCreatedWindow: NSNib.Name = "dummyNibNameForProgrammaticallyCreatedWindow"
}

#endif
