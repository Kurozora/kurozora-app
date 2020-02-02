//
//  KModalTransition.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SPStorkController

class KModalTransition: UIStoryboardSegue {
	// swiftlint:disable weak_delegate
	public var transitioningDelegate: SPStorkTransitioningDelegate?

	override func perform() {
		if #available(iOS 13.0, macCatalyst 13, *) {
			destination.modalPresentationStyle = .custom
			source.present(destination, animated: true, completion: nil)
		} else {
			transitioningDelegate = transitioningDelegate ?? SPStorkTransitioningDelegate()
			transitioningDelegate?.showIndicator = false
			destination.transitioningDelegate = transitioningDelegate
			destination.modalPresentationStyle = .custom
			source.present(destination, animated: true, completion: nil)
		}
	}
}
