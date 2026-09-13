//
//  KSearchBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Obfuscation
import UIKit

/// A search bar that swaps its scope bar for a row of chips once a search has been run.
class KSearchBar: UISearchBar {
	// MARK: - Views
	/// The chips shown in place of the scope bar.
	let chipsView = KChipsView()

	/// The stand-in for the scope bar UIKit draws.
	private let scopeSegmentedControl = UISegmentedControl()

	// MARK: - Properties
	/// Whether the chips take the place of the scope bar.
	var showsChips = false {
		didSet {
			self.layoutScopeViews()
		}
	}

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
		self.chipsView.alpha = 0.0
		self.scopeSegmentedControl.addTarget(self, action: #selector(self.scopeSegmentedControlDidChange(_:)), for: .valueChanged)
	}

	/// Moves the stand-in and the chips into the scope bar's container, which UIKit builds lazily.
	private func attachScopeViews() {
		self.systemScopeBar?.isHidden = true

		guard let scopeBarContainerView = self.scopeBarContainerView else { return }

		if self.scopeSegmentedControl.superview !== scopeBarContainerView {
			scopeBarContainerView.addSubview(self.scopeSegmentedControl)
		}

		if self.chipsView.superview !== scopeBarContainerView {
			scopeBarContainerView.addSubview(self.chipsView)
		}
	}

	/// Places the scope stand-in and the chips, sliding whichever is on its way out.
	private func layoutScopeViews() {
		guard let scopeBarContainerView = self.scopeBarContainerView else { return }

		if let systemScopeBar = self.systemScopeBar {
			self.scopeSegmentedControl.frame.size = systemScopeBar.frame.size
			self.scopeSegmentedControl.frame.origin.x = systemScopeBar.frame.origin.x
			self.scopeSegmentedControl.frame.origin.y = self.showsChips ? -systemScopeBar.frame.height : systemScopeBar.frame.origin.y
		}

		self.scopeSegmentedControl.alpha = self.showsChips ? 0.0 : 1.0

		self.chipsView.frame.size = scopeBarContainerView.frame.size
		self.chipsView.frame.origin.x = 0.0
		self.chipsView.frame.origin.y = self.showsChips ? 0.0 : scopeBarContainerView.frame.height
		self.chipsView.alpha = self.showsChips ? 1.0 : 0.0
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
