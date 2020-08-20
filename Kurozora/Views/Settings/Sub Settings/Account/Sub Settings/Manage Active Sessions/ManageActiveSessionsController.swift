//
//  ManageActiveSessionsController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import CoreLocation
import MapKit
import SCLAlertView
import SwipeCellKit

class ManageActiveSessionsController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var mapView: MKMapView!

	// MARK: - Properties
	var dismissEnabled: Bool = false
	var sessions: [Session] = [] {
		didSet {
			createAnnotations()
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}
	var nextPageURL: String?

	// Map & Location
	var pointAnnotation: MKPointAnnotation!
	var pinAnnotationView: MKPinAnnotationView!
	let locationManager = CLLocationManager()

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if dismissEnabled {
			let closeButton: UIBarButtonItem
			if #available(iOS 13.0, macCatalyst 13.0, *) {
				closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss(_:)))
			} else {
				closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismiss(_:)))
			}
			self.navigationItem.leftBarButtonItem = closeButton
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Fetch sessions
		DispatchQueue.global(qos: .background).async {
			self.fetchSessions()
		}

		// Configure map view
		mapView.showsUserLocation = true

		if CLLocationManager.locationServicesEnabled() == true {
			let authorizationStatus: CLAuthorizationStatus!

			if #available(iOS 14.0, macCatalyst 14.0, *) {
				authorizationStatus = locationManager.authorizationStatus()
			} else {
				authorizationStatus = CLLocationManager.authorizationStatus()
			}

			switch authorizationStatus {
			case .restricted, .denied, .notDetermined:
				locationManager.requestWhenInUseAuthorization()
			default: break
			}

			locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
			locationManager.delegate = self
			locationManager.startUpdatingLocation()

		} else {
			print("Please turn on location services or GPS")
		}

		// Configure table view height
		tableView.tableHeaderView?.frame.size.height = self.view.frame.height / 3
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		if UIDevice.isLandscape {
			self.tableView.tableHeaderView?.frame.size.height = self.view.frame.height / 3
		} else {
			DispatchQueue.main.async {
				self.tableView.tableHeaderView?.frame.size.height = self.view.frame.height / 3
			}
		}
	}

	// MARK: - Functions
	/// Fetches sessions for the current user from the server.
	private func fetchSessions() {
		KService.getSessions(next: nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let sessionResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.sessions = []
				}

				// Append new data and save next page url
				self.sessions.append(contentsOf: sessionResponse.data)

				self.nextPageURL = sessionResponse.next
			case .failure: break
			}
		}
	}

	/**
		Dismisses the current view controller.

		- Parameter sender: The object requesting the dismiss of the current view controller.
	*/
	@objc func dismiss(_ sender: Any?) {
		self.dismiss(animated: true, completion: nil)
	}

	/// Creates annotations and adds them to the map view.
	private func createAnnotations() {
		let otherUserSessions = sessions

		for userSession in otherUserSessions {
			let annotation = ImageAnnotation()
			if let deviceName = userSession.relationships.platform.data.first?.attributes.deviceModel {
				annotation.title = deviceName

				switch deviceName {
				case "iPhone":
					annotation.image = R.image.devices.iPhone()
				case "iPad":
					annotation.image = R.image.devices.iPad()
				case "Apple TV":
					annotation.image = R.image.devices.appleTV()
				case "MacBook":
					annotation.image = R.image.devices.macBook()
				default:
					annotation.image = R.image.devices.other()
				}
			}

			if let userSessionLocation = userSession.relationships.location.data.first {
				if let latitude = userSessionLocation.attributes.latitude, let longitude = userSessionLocation.attributes.longitude {
					annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
				}
			}

			mapView.addAnnotation(annotation)
		}

		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}

	/**
		Removes a session with the given session cell as data source.

		- Parameter otherSessionsCell: The session cell from which the data is fetched to decide which session to remove.
	*/
	private func removeSession(_ otherSessionsCell: OtherSessionsCell) {
		let alertView = SCLAlertView()
		alertView.addButton("Yes!", action: {
			guard let sessionID = otherSessionsCell.session?.id else { return }

			KService.deleteSession(sessionID) { [weak self] result in
				guard let self = self else { return }

				switch result {
				case .success:
					// Get index path for cell
					if let indexPath = otherSessionsCell.indexPath {
						// Start delete process
						self.tableView.beginUpdates()
						self.sessions.remove(at: indexPath.row)
						self.tableView.deleteRows(at: [indexPath], with: .left)
						if self.sessions.count == 0 {
							self.tableView.deleteSections([1], with: .left)
						}
						self.tableView.endUpdates()
					}
				case .failure: break
				}
			}
		})

		alertView.showNotice("Confirm deletion", subTitle: "Are you sure you want to delete this session?", closeButtonTitle: "Maybe not now")
	}
}

// MARK: - UITableViewDelegate
extension ManageActiveSessionsController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfRows = tableView.numberOfRows()

		if indexPath.row == numberOfRows - 5 {
			if self.nextPageURL != nil {
				self.fetchSessions()
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ManageActiveSessionsController {
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Current Session"
		} else {
			return "Other Sessions"
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return sessions.isEmpty ? 1 : 2
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : sessions.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			guard let currentSessionCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.currentSessionCell, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.currentSessionCell.identifier)")
			}
			currentSessionCell.session = User.current?.relationships?.sessions?.data.first
			return currentSessionCell
		} else {
			let otherSessionsCount = self.sessions.count

			// No other sessions
			if otherSessionsCount == 0 {
				guard let noSessionsCell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noSessionsCell, for: indexPath) else {
					fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.noSessionsCell.identifier)")
				}
				return noSessionsCell
			}

			// Other sessions found
			guard let otherSessionsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.otherSessionsCell, for: indexPath) else {
					fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.otherSessionsCell.identifier)")
			}
			otherSessionsCell.delegate = self
			otherSessionsCell.session = self.sessions[indexPath.row]
			return otherSessionsCell
		}
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return indexPath.section != 0
	}
}

// MARK: - SwipeTableViewCellDelegate
extension ManageActiveSessionsController: SwipeTableViewCellDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		switch orientation {
		case .right:
			let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] _, indexPath in
				guard let self = self else { return }
				if let otherSessionsCell = tableView.cellForRow(at: indexPath) as? OtherSessionsCell {
					self.removeSession(otherSessionsCell)
				}
			}
			deleteAction.backgroundColor = .clear
			deleteAction.image = R.image.trash_circle()
			deleteAction.textColor = .kLightRed
			deleteAction.font = .systemFont(ofSize: 13)
			deleteAction.transitionDelegate = ScaleTransition.default
			return [deleteAction]
		case .left:
			return nil
		}
	}

	func visibleRect(for tableView: UITableView) -> CGRect? {
		return tableView.safeAreaLayoutGuide.layoutFrame
	}

	func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
		var options = SwipeOptions()

		switch orientation {
		case .right:
			options.expansionStyle = .selection
		case .left:
			options.expansionStyle = .none
		}

		options.transitionStyle = .reveal
		options.expansionDelegate = ScaleAndAlphaExpansion.default
		options.buttonSpacing = 4
		options.backgroundColor = .clear
		return options
	}
}

// MARK: - MKMapViewDelegate
extension ManageActiveSessionsController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation.isEqual(mapView.userLocation) {
			return nil
		}

		if !annotation.isKind(of: ImageAnnotation.self) {
			var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
			if pinAnnotationView == nil {
				pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
			}
			return pinAnnotationView
		}

		var annotationView = MKMarkerAnnotationView()
		if let markerAnnotationView: MKMarkerAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? MKMarkerAnnotationView {
			annotationView = markerAnnotationView
		} else {
			annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
			let annotation = annotation as! ImageAnnotation
			annotationView.glyphImage = annotation.image
		}

		annotationView.markerTintColor = .kurozora

		return annotationView
	}
}

// MARK: - CLLocationManagerDelegate
extension ManageActiveSessionsController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Unable to access your current location")
	}
}
