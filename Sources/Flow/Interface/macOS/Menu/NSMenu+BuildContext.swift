//
//  NSMenu+BuildContext.swift
//  
//
//  Created by Zhu Shengqi on 2021/3/18.
//

#if os(macOS)

import Foundation
import AppKit

extension NSMenu {
	public func withBuildContext(_ body: (_ context: BuildContext) -> Void) -> NSMenu {
		let buildContext = BuildContext(menu: self)

		body(buildContext)

		return self
	}

	public struct BuildContext {
		private let menu: NSMenu

		init(menu: NSMenu) {
			self.menu = menu
		}

		public func addSeparator() {
			let separatorItem = NSMenuItem.separator()
			menu.addItem(separatorItem)
		}

		@discardableResult
		public func addSubmenu(title: String, _ body: (_ context: BuildContext) -> Void) -> NSMenuItem {
			let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
			menu.addItem(menuItem)

			let submenu = NSMenu(title: title)
			menuItem.submenu = submenu

			let subcontext = BuildContext(menu: submenu)
			body(subcontext)

			return menuItem
		}

		@discardableResult
		public func addSubmenu(_ submenu: NSMenu) -> NSMenuItem {
			let menuItem = NSMenuItem(title: submenu.title, action: nil, keyEquivalent: "")
			menu.addItem(menuItem)

			menuItem.submenu = submenu

			return menuItem
		}

		@discardableResult
		public func addItem(title: String, action: Selector?, keyEquivalent: String = "", keyModifiers: NSEvent.ModifierFlags = []) -> NSMenuItem {
			let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
			menuItem.keyEquivalentModifierMask = keyModifiers

			menu.addItem(menuItem)

			return menuItem
		}
	}
}

#endif
