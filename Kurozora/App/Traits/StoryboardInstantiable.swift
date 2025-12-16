//
//  StoryboardInstantiable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/12/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

/// A protocol that provides functionality to instantiate view controllers from storyboards.
protocol StoryboardInstantiable where Self: UIViewController {
	/// The name of the storyboard where the view controller is located.
	static var storyboardName: String { get }

	/// The bundle where the storyboard is located. Default is `Bundle.main`.
	static var storyboardBundle: Bundle { get }

	/// The identifier of the view controller in the storyboard. Default is the class name.
	static var storyboardIdentifier: String { get }
}

extension StoryboardInstantiable {
	static var storyboardBundle: Bundle { .main }
	static var storyboardIdentifier: String { String(describing: self) }

	/// Instantiates the view controller from its storyboard.
	static func instantiate() -> Self {
		let storyboard = UIStoryboard(name: self.storyboardName, bundle: self.storyboardBundle)

		guard let vc = storyboard.instantiateViewController(withIdentifier: self.storyboardIdentifier) as? Self else {
			#if DEBUG
			fatalError("\(Self.self) not found in storyboard '\(self.storyboardName)'")
			#else
			return Self()
			#endif
		}

		return vc
	}
}
