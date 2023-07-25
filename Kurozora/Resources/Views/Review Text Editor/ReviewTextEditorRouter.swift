//
//  ReviewTextEditorRouter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

protocol ReviewTextEditorRoutingLogic {
	func routeToSomewhere()
}

protocol ReviewTextEditorDataPassing {
	var dataStore: ReviewTextEditorDataStore? { get }
}

// MARK: - Router
final class ReviewTextEditorRouter: ReviewTextEditorDataPassing {
	weak var viewController: ReviewTextEditorViewController?
	var dataStore: ReviewTextEditorDataStore?
}

// MARK: - RoutingLogic
extension ReviewTextEditorRouter: ReviewTextEditorRoutingLogic {
	func routeToSomewhere() {
//        let destinationVC = ReviewTextEditorViewController()
//		if let sourceDS = self.dataStore, let destinationDS = destinationVC.router?.dataStore {
//            passData(from: sourceDS, to: destinationDS)
//        }
//
//		self.viewController?.present(destinationVC, animated: true, completion: nil)
	}
}

// MARK: - PassData
extension ReviewTextEditorRouter {
//	/// Provide the destination dataStore with data from the source dataStore.
//	func passData(from source: ReviewTextEditorDataStore, to destination: ReviewTextEditorDataStore) {
//		destination.name = source.name
//	}
}
