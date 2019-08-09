//
//  ManageActiveSessionsController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/06/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import SwifterSwift
import MapKit
import CoreLocation

class ManageActiveSessionsController: UIViewController {
	@IBOutlet var tableView: UITableView!
	@IBOutlet weak var mapView: MKMapView!

	var dismissEnabled: Bool = false
	var sessions: UserSessions? {
		didSet {
			createAnnotations()
			tableView.reloadData()
		}
	}
	var pointAnnotation: MKPointAnnotation!
	var pinAnnotationView: MKPinAnnotationView!
	let locationManager = CLLocationManager()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		if dismissEnabled {
			let closeButton = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(dismiss(_:)))
			self.navigationItem.leftBarButtonItem  = closeButton
		}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		NotificationCenter.default.addObserver(self, selector: #selector(removeSessionFromTable(_:)), name: NSNotification.Name(rawValue: "removeSessionFromTable"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(addSessionToTable(_:)), name: NSNotification.Name(rawValue: "addSessionToTable"), object: nil)

		fetchSessions()

		mapView.delegate = self
		mapView.showsUserLocation = true

		if CLLocationManager.locationServicesEnabled() == true {
			if CLLocationManager.authorizationStatus() == .restricted ||
				CLLocationManager.authorizationStatus() == .denied ||
				CLLocationManager.authorizationStatus() == .notDetermined {
				locationManager.requestWhenInUseAuthorization()
			}

			locationManager.desiredAccuracy = 1.0
			locationManager.delegate = self
			locationManager.startUpdatingLocation()

		} else {
			print("Please turn on location services or GPS")
		}

        // Setup table view
		tableView.tableHeaderView?.height = self.view.frame.height / 3
        tableView.dataSource = self
        tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension
    }

	// MARK: - Functions
	private func fetchSessions() {
		Service.shared.getSessions( withSuccess: { (sessions) in
			DispatchQueue.main.async() {
				self.sessions = sessions
			}
		})
	}

	@objc func dismiss(_ sender: Any?) {
		self.dismiss(animated: true, completion: nil)
	}

	private func createAnnotations() {
		guard let otherSessions = sessions?.otherSessions else { return }

		for session in otherSessions {
			let annotation = ImageAnnotation()
			if let deviceString = session.device, let range = deviceString.range(of: " on ") {
				let device = deviceString[deviceString.startIndex..<range.lowerBound]
				annotation.title = "\(device)"

				if device.contains("iPhone") {
					annotation.image = #imageLiteral(resourceName: "iphone")
				} else if device.contains("iPad") {
					annotation.image = #imageLiteral(resourceName: "ipad")
				} else if device.contains("Apple TV") {
					annotation.image = #imageLiteral(resourceName: "apple_tv")
				} else if device.contains("MacBook") {
					annotation.image = #imageLiteral(resourceName: "macbook")
				} else {
					annotation.image = #imageLiteral(resourceName: "other_devices")
				}
			}

			if let latitude = session.location?.latitude, let longitude = session.location?.longitude {
				annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
			}

			mapView.addAnnotation(annotation)
		}

		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}

	private func removeSession(_ otherSessionsCell: OtherSessionsCell) {
		let alertView = SCLAlertView()
		alertView.addButton("Yes!", action: {
			let sessionSecret = otherSessionsCell.sessions?.id

			Service.shared.deleteSession(with: sessionSecret, withSuccess: { (success) in
				if success {
					// Get index path for cell
					if let indexPath = self.tableView.indexPath(for: otherSessionsCell) {
						// Start delete process
						self.tableView.beginUpdates()
						self.sessions?.otherSessions?.remove(at: indexPath.row)
						self.tableView.deleteRows(at: [indexPath], with: .left)
						self.tableView.endUpdates()
					}
				}
			})
		})

		alertView.showNotice("Confirm deletion", subTitle: "Are you sure you want to delete this session?", closeButtonTitle: "Maybe not now")
	}

	@objc func removeSessionFromTable(_ notification: NSNotification) {
		if let sessionID = notification.userInfo?["session_id"] as? Int {
			self.tableView.beginUpdates()
			let sessionIndex = self.sessions?.otherSessions?.firstIndex(where: { (json) -> Bool in
				return json.id == sessionID
			})

			if let sessionIndex = sessionIndex, sessionIndex != 0 {
				self.sessions?.otherSessions?.remove(at: sessionIndex)
				self.tableView.deleteRows(at: [IndexPath(row: 0, section: sessionIndex)], with: .left)
			}
			self.tableView.endUpdates()
		}
	}

	@objc func addSessionToTable(_ notification: NSNotification) {
		if let sessionID = notification.userInfo?["id"] as? Int, let device = notification.userInfo?["device"] as? String, let ip = notification.userInfo?["ip"] as? String, let lastValidated = notification.userInfo?["last_validated"] as? String {
			guard let sessionsCount = sessions?.otherSessions?.count else { return }
			let newSession: JSON = ["id": sessionID,
									"device": device,
									"ip": ip,
									"last_validated": lastValidated
			]
			
			if let newSessionElement = try? UserSessionsElement(json: newSession) {
				self.tableView.beginUpdates()
				self.sessions?.otherSessions?.append(newSessionElement)
				self.tableView.insertRows(at: [[1, sessionsCount]], with: .right)
				self.tableView.endUpdates()
			}
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		if UIDevice.isLandscape() {
			self.tableView.tableHeaderView?.height = self.view.frame.height / 3
		} else {
			DispatchQueue.main.async() {
				self.tableView.tableHeaderView?.height = self.view.frame.height / 3
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ManageActiveSessionsController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "Current Session"
		} else {
			return "Other Sessions"
		}
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		} else {
			guard let sessionsCount = sessions?.otherSessions?.count else { return 1 }
			return sessionsCount
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let currentSessionCell = tableView.dequeueReusableCell(withIdentifier: "CurrentSessionCell", for: indexPath) as! CurrentSessionCell
			currentSessionCell.session = sessions?.currentSessions
			return currentSessionCell
		} else {
			let otherSessionsCount = sessions?.otherSessions?.count

			// No other sessions
			if otherSessionsCount == nil || otherSessionsCount == 0 {
				let noSessionsCell = self.tableView.dequeueReusableCell(withIdentifier: "NoSessionsCell", for: indexPath) as! NoSessionsCell
				return noSessionsCell
			}

			// Other sessions found
			let otherSessionsCell = tableView.dequeueReusableCell(withIdentifier: "OtherSessionsCell", for: indexPath) as! OtherSessionsCell

			otherSessionsCell.delegate = self
			otherSessionsCell.sessions = sessions?.otherSessions?[indexPath.row]

			return otherSessionsCell
		}
	}
}

// MARK: - UITableViewDelegate
extension ManageActiveSessionsController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.textLabel?.font = UIFont.systemFont(ofSize: 15)
			headerView.textLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
}

// MARK: - OtherSessionsCellDelegate
extension ManageActiveSessionsController: OtherSessionsCellDelegate {
	func removeSession(for otherSessionsCell: OtherSessionsCell) {
		self.removeSession(otherSessionsCell)
	}
}

extension ManageActiveSessionsController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//		guard !(annotation is MKPointAnnotation) else { return nil }

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

		if #available(iOS 11.0, *) {
			var annotationView = MKMarkerAnnotationView()
			if let markerAnnotationView: MKMarkerAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? MKMarkerAnnotationView {
				annotationView = markerAnnotationView
			} else {
				annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
				let annotation = annotation as! ImageAnnotation
				annotationView.glyphImage = annotation.image
			}

			annotationView.markerTintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)

			return annotationView
		}

		var imageAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation")
		imageAnnotationView = ImageAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")

		let annotation = annotation as! ImageAnnotation
		imageAnnotationView?.image = annotation.image
		imageAnnotationView?.annotation = annotation
		imageAnnotationView?.canShowCallout = true

		return imageAnnotationView

//		else {
//			let annotationIdentifier = "pin"
//			var annotationView: MKAnnotationView?
//
//			if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
//				annotationView = dequeuedAnnotationView
//				annotationView?.annotation = annotation
//			} else {
//				annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//				annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//			}
//
//			if let annotationView = annotationView {
//				annotationView.canShowCallout = true
//				annotationView.image = #imageLiteral(resourceName: "default_avatar")
//			}
//
//			return annotationView
//		}
	}
}

extension ManageActiveSessionsController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//		if let location = locations.last {
//			let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//			let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//			self.mapView.setRegion(region, animated: true)
//		}
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Unable to access your current location")
	}
}
