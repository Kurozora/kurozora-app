//
//  NibLoadable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/12/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

/// A protocol that allows conforming types to provide a nib for loading `UINib`-based views.
protocol NibLoadable: AnyObject {
	// MARK: - Properties
	/// The nib associated with the conforming type.
	static var nib: UINib { get }

	/// The name of the nib file associated with the conforming type.
	static var nibName: String { get }
}

extension NibLoadable {
	static var nibName: String {
		String(describing: self)
	}

	static var nib: UINib {
		UINib(nibName: self.nibName, bundle: Bundle(for: self))
	}
}

// MARK: - UICollectionViewCell
extension UICollectionViewCell: NibLoadable {}

// MARK: - UITableViewCell
extension UITableViewCell: NibLoadable {}
