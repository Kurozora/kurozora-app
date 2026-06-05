//
//  UIView+Localization.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import ObjectiveC
import UIKit

private final class L10nBindingStore {
	var bindings: [String: () -> Void] = [:]
}

private var l10nBindingStoreKey: UInt8 = 0

extension UIView {
	/// The per-view store of localized re-apply closures, created lazily on first binding.
	private var l10nBindingStore: L10nBindingStore? {
		get { objc_getAssociatedObject(self, &l10nBindingStoreKey) as? L10nBindingStore }
		set { objc_setAssociatedObject(self, &l10nBindingStoreKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	/// Records, replaces, or clears the localization binding for a property.
	///
	/// - Parameters:
	///    - key: The property identifier the binding applies to.
	///    - assignedValue: The string just assigned to the property.
	///    - apply: A closure that assigns a freshly resolved string back to the property.
	func registerLocalizationBinding(forKey key: String, assignedValue: String?, apply: @escaping (String) -> Void) {
		guard Thread.isMainThread, !L10nProvenance.isReapplying else { return }

		let resolver = L10nProvenance.pending
		L10nProvenance.pending = nil

		guard let resolver = resolver, let assignedValue = assignedValue, resolver() == assignedValue else {
			self.l10nBindingStore?.bindings[key] = nil
			return
		}

		let store = self.l10nBindingStore ?? L10nBindingStore()
		store.bindings[key] = { apply(resolver()) }
		self.l10nBindingStore = store
	}

	/// Re-applies every recorded localization binding on this view and its descendants.
	func reapplyLocalizationBindingsTree() {
		L10nProvenance.isReapplying = true
		self.reapplyLocalizationBindings()
		L10nProvenance.isReapplying = false
	}

	private func reapplyLocalizationBindings() {
		self.l10nBindingStore?.bindings.values.forEach { $0() }
		self.subviews.forEach { $0.reapplyLocalizationBindings() }
	}
}
