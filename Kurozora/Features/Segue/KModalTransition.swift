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
	public var transitioningDelegate: SPStorkTransitioningDelegate?

	override func perform() {
		transitioningDelegate = transitioningDelegate ?? SPStorkTransitioningDelegate()
		transitioningDelegate?.showIndicator = false
		destination.transitioningDelegate = transitioningDelegate
		destination.modalPresentationStyle = .custom
		//	super.perform()
		source.present(destination, animated: true, completion: nil)
	}
}
