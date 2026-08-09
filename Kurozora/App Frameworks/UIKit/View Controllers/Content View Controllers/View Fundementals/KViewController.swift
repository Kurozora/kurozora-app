//
//  KViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// A supercharged object that manages a view hierarchy for your UIKit app.
///
/// This implementation of [UIViewController](apple-reference-documentation://hs37A1uTs6) implements the following behavior:
/// - The view controller subscribes to the `theme_backgroundColor` of the currently selected theme.
///
/// Create a custom subclass of `KViewController` for each view that you manage.
///
/// - Tag: KViewController
class KViewController: UIViewController, SegueHandler {
	// MARK: - Properties
	/// The gradient view object of the view controller.
	private var gradientView: GradientView = {
		let gradientView = GradientView()
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		gradientView.gradientLayer?.theme_colors = KThemePicker.backgroundColors.gradientPicker
		return gradientView
	}()

	/// The object restoring the scroll position after a second status bar tap.
	private lazy var statusBarScrollRestorer: StatusBarScrollRestorer = StatusBarScrollRestorer()

	/// The scroll view returned to its previous position when the status bar is tapped a second time.
	///
	/// Subclasses managing their own scroll view return it here and forward
	/// `scrollViewShouldScrollToTop(_:)` to [statusBarScrollRestorer](x-source-tag://KViewController-statusBarScrollRestorer).
	///
	/// By default, this property returns `nil`.
	///
	/// - Tag: KViewController-scrollViewForStatusBarRestoration
	var scrollViewForStatusBarRestoration: UIScrollView? {
		return nil
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		self.sharedInit()
	}

	// MARK: - Functions
	/// Returns whether UIKit should perform its own scroll to the top of the given scroll view.
	///
	/// - Parameter scrollView: The scroll view UIKit is about to scroll.
	///
	/// - Returns: `true` to let UIKit scroll to the top, `false` when the previous position is restored instead.
	///
	/// - Tag: KViewController-statusBarScrollRestorer
	func shouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		return self.statusBarScrollRestorer.shouldScrollToTop(scrollView)
	}
	/// The shared init of the view controller.
	private func sharedInit() {
		// Configure the gradient view.
		self.configureGradientView()

		#if !targetEnvironment(macCatalyst)
		if let scrollViewForStatusBarRestoration = self.scrollViewForStatusBarRestoration {
			self.statusBarScrollRestorer.install(restoring: scrollViewForStatusBarRestoration)
		}
		#endif
	}

	/// Configures the gradient view with default values.
	fileprivate func configureGradientView() {
		self.view.addSubview(self.gradientView)
		self.view.sendSubviewToBack(self.gradientView)

		NSLayoutConstraint.activate([
			self.gradientView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.gradientView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.gradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.gradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
		])
	}

	// MARK: - SegueHandler
	func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		return nil
	}

	func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {}
}

// MARK: - SeguePerforming
extension KViewController: SeguePerforming {
	func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
		self.performSegue(withIdentifier: identifier.rawValue, sender: sender)
	}

	func show(_ identifier: SegueIdentifier, sender: Any?) {
		guard let destination = makeDestination(for: identifier) else { return }
		self.prepare(for: identifier, destination: destination, sender: sender)
		self.show(destination, sender: sender)
	}

	func showDetailViewController(_ identifier: SegueIdentifier, sender: Any?) {
		guard let destination = makeDestination(for: identifier) else { return }
		self.prepare(for: identifier, destination: destination, sender: sender)
		self.showDetailViewController(destination, sender: sender)
	}

	func present(_ identifier: SegueIdentifier, sender: Any?) {
		guard let destination = makeDestination(for: identifier) else { return }
		self.prepare(for: identifier, destination: destination, sender: sender)
		self.present(destination, animated: true)
	}

	func showSecondary(_ identifier: SegueIdentifier, sender: Any?) {
		guard let destination = makeDestination(for: identifier) else { return }
		self.prepare(for: identifier, destination: destination, sender: sender)

		guard let splitViewController = self.splitViewController else {
			self.show(destination, sender: sender)
			return
		}

		splitViewController.setViewController(KNavigationController(rootViewController: destination), for: .secondary)
		splitViewController.show(.secondary)
	}
}
