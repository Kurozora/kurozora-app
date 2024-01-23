//
//  ImageAnnotation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import MapKit

class ImageAnnotation: NSObject, MKAnnotation {
	// MARK: - Properties
	var coordinate: CLLocationCoordinate2D
	var title: String?
	var subtitle: String?
	var image: UIImage?
	var colour: UIColor?

	// MARK: - Initializers
	override init() {
		self.coordinate = CLLocationCoordinate2D()
		self.title = nil
		self.subtitle = nil
		self.image = nil
		self.colour = UIColor.white
	}
}

class ImageAnnotationView: MKAnnotationView {
	// MARK: - Properties
	private var imageView: UIImageView!
	override var image: UIImage? {
		get {
			return self.imageView.image
		}
		set {
			self.imageView.image = newValue
		}
	}

	// MARK: - Initializers
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

		self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
		self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
		self.addSubview(self.imageView)

		self.imageView.layerCornerRadius = self.imageView.height / 2
		self.imageView.layerBorderColor = .green
		self.imageView.layer.borderWidth = 2
		self.imageView.layer.masksToBounds = true
	}
}
