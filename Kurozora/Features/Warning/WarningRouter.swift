//
//  WarningRouter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol WarningRoutingLogic {
	func routeToSomewhere()
}

protocol WarningDataPassing {
	var dataStore: WarningDataStore? { get }
}

// MARK: - Router
final class WarningRouter: WarningDataPassing {
	weak var viewController: WarningViewController?
	var dataStore: WarningDataStore?
}

// MARK: - RoutingLogic
extension WarningRouter: WarningRoutingLogic {
	func routeToSomewhere() {
//        let destinationVC = WarningViewController()
//		if let sourceDS = self.dataStore, let destinationDS = destinationVC.router?.dataStore {
//            passData(from: sourceDS, to: destinationDS)
//        }
//
//		self.viewController?.present(destinationVC, animated: true, completion: nil)
	}
}

// MARK: - PassData
extension WarningRouter {
//	/// Provide the destination dataStore with data from the source dataStore.
//	func passData(from source: WarningDataStore, to destination: WarningDataStore) {
//		destination.name = source.name
//	}
}
