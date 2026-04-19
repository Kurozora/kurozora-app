//
//  LibraryViewController+Views.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

// MARK: - Configuration
extension LibraryViewController {
	/// Builds and wires every view owned by the controller.
	func configureView() {
		self.configureNavigationItems()
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	/// Configures the content-region views that sit below the navigation bar.
	private func configureViews() {
		self.configureScrollViewContentView()
		self.configureScrollView()
		self.configureLibraryKindSegmentedControl()
		self.configureLibraryKindBarButtonItem()
		self.configureToolbar()
	}

	/// Configures the sort type bar button item.
	private func configureSortTypeBarButtonItem() {
		self.sortTypeBarButtonItem.title = L10n.sort
		self.sortTypeBarButtonItem.image = UIImage(systemName: "line.3.horizontal.decrease.circle")
	}

	/// Configures the more bar button item.
	private func configureMoreBarButtonItem() {
		self.moreBarButtonItem.title = L10n.more
		self.moreBarButtonItem.image = UIImage(systemName: "ellipsis.circle")
	}

	/// Configures the profile bar button item.
	private func configureProfileBarButtonItem() {
		self.profileBarButtonItem = ProfileBarButtonItem(primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }

			Task {
				await self.segueToProfile()
			}
		})

		if let profileBarButtonItem = self.profileBarButtonItem {
			self.navigationItem.rightBarButtonItems?.insert(profileBarButtonItem, at: 0)
		}

		self.configureUserDetails()
	}

	/// Configures the navigation items hosted by the view's navigation bar.
	fileprivate func configureNavigationItems() {
		self.configureSortTypeBarButtonItem()
		self.configureMoreBarButtonItem()
		self.configureProfileBarButtonItem()
	}

	/// Configures the secondary toolbar that holds the library-kind segmented control.
	private func configureToolbar() {
		self.toolbar.translatesAutoresizingMaskIntoConstraints = false
		self.toolbar.delegate = self
		self.toolbar.isTranslucent = false
		self.toolbar.backgroundColor = .clear
		self.toolbar.barStyle = .default
		self.toolbar.theme_tintColor = KThemePicker.tintColor.rawValue
		self.toolbar.theme_barTintColor = KThemePicker.barTintColor.rawValue
	}

	/// Configures the bar button item that hosts the library-kind segmented control.
	private func configureLibraryKindBarButtonItem() {
		self.libraryKindBarButtonItem.customView = self.libraryKindSegmentedControl

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.libraryKindBarButtonItem.hidesSharedBackground = true
		}
	}

	/// Configures the library-kind segmented control with one segment per ``KKLibrary/Kind``.
	private func configureLibraryKindSegmentedControl() {
		let items = KKLibrary.Kind.allCases.map { libraryKind in
			UIAction(title: libraryKind.stringValue) { [weak self] _ in
				guard let self = self else { return }
				self.libraryKindSegmentedControlDidChange(to: libraryKind)
			}
		}
		self.libraryKindSegmentedControl = UISegmentedControl(items: items)
		self.libraryKindSegmentedControl.selectedSegmentIndex = self.libraryKind.rawValue
	}

	/// Configures the shell view that hosts the paged scroll content.
	private func configureScrollViewContentView() {
		self.scrollViewContentView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollViewContentView.backgroundColor = nil
	}

	/// Configures the outer scroll view that tracks inner pager-scroll progress.
	private func configureScrollView() {
		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
	}

	/// Adds the scroll view, toolbar and shell into the view hierarchy in the correct z-order.
	private func configureViewHierarchy() {
		self.scrollView.addSubview(self.scrollViewContentView)
		self.toolbar.setItems([self.libraryKindBarButtonItem], animated: false)

		self.view.addSubview(self.scrollView)
		self.view.addSubview(self.toolbar)

		self.view.sendSubviewToBack(self.scrollView)
	}

	/// Activates the Auto Layout constraints for the scroll view, shell and toolbar.
	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.scrollViewContentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
			self.scrollViewContentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
			self.scrollViewContentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
			self.scrollViewContentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
			self.scrollViewContentView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
			self.scrollViewContentView.heightAnchor.constraint(equalTo: self.view.heightAnchor),

			self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
			self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -34),

			self.toolbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.toolbar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			self.toolbar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
		])
	}
}

// MARK: - UIToolbarDelegate
extension LibraryViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}
