//
//  KSearchBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Obfuscation
import UIKit

/// A search bar that draws its own scope bar.
class KSearchBar: UISearchBar {
	// MARK: - Views
	/// The stand-in for the scope bar UIKit draws.
	private let scopeSegmentedControl = UISegmentedControl()

	// MARK: - Properties
	override var scopeButtonTitles: [String]? {
		didSet {
			self.scopeSegmentedControl.segmentTitles = self.scopeButtonTitles ?? []
			self.scopeSegmentedControl.selectedSegmentIndex = self.selectedScopeButtonIndex
		}
	}

	override var selectedScopeButtonIndex: Int {
		didSet {
			self.scopeSegmentedControl.selectedSegmentIndex = self.selectedScopeButtonIndex
		}
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.sharedInit()
	}

	// MARK: - View
	override func didMoveToSuperview() {
		super.didMoveToSuperview()

		self.attachScopeViews()
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.attachScopeViews()
		self.layoutScopeViews()
	}

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		self.scopeSegmentedControl.addTarget(self, action: #selector(self.scopeSegmentedControlDidChange(_:)), for: .valueChanged)
	}

	/// Moves the stand-in into the scope bar's container.
	private func attachScopeViews() {
		self.systemScopeBar?.isHidden = true

		guard let scopeBarContainerView = self.scopeBarContainerView else { return }
		guard self.scopeSegmentedControl.superview !== scopeBarContainerView else { return }

		scopeBarContainerView.addSubview(self.scopeSegmentedControl)
	}

	/// Places the scope stand-in over the scope bar.
	private func layoutScopeViews() {
		guard let systemScopeBar = self.systemScopeBar else { return }

		self.scopeSegmentedControl.frame = systemScopeBar.frame
	}

	/// Reports the stand-in's selection as a scope change.
	///
	/// - Parameter sender: The stand-in that changed.
	@objc private func scopeSegmentedControlDidChange(_ sender: UISegmentedControl) {
		self.selectedScopeButtonIndex = sender.selectedSegmentIndex
		self.delegate?.searchBar?(self, selectedScopeButtonIndexDidChange: sender.selectedSegmentIndex)
	}
}

// MARK: - Scope bar
private extension UISearchBar {
	/// The scope bar the search bar draws.
	var systemScopeBar: UIView? {
		let key = #obfuscated("_scopeBar")
		guard self.responds(to: NSSelectorFromString(key)) else { return nil }
		return self.value(forKey: key) as? UIView
	}

	/// The view holding the scope bar.
	var scopeBarContainerView: UIView? {
		let key = #obfuscated("_scopeBarContainerView")
		guard self.responds(to: NSSelectorFromString(key)) else { return nil }
		return self.value(forKey: key) as? UIView
	}
}
