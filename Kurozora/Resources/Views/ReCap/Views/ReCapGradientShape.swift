//
//  ReCapGradientShape.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// The blob outlines the Re:CAP gradients are cut from.
enum ReCapGradientShape {
	// MARK: - Cases
	case a
	case b
	case c
	case d
	case e
	case f
	case g
	case h
	case i

	// MARK: - Properties
	/// The outline of the shape in a unit square.
	private var pathData: String {
		switch self {
		case .a:
			return "M.0382 .1529C.1531 .3536 .0787 .9461 .209 .9972C.3393 1.0483 .7237 .3802 .9562 .2839C1.1887 .1876 .4279 -.0109 .2582 .0005C.0885 .0118 -.0767 -.0478 .0382 .1529Z"
		case .b:
			return "M.0365 .9123C.14 1.2057 .4663 .6628 .5837 .7376C.701 .8123 .9567 .5931 .9982 .3232C1.0396 .0534 .3729 -.0143 .2201 .0024C.0672 .019 -.067 .6189 .0365 .9123Z"
		case .c:
			return "M.023 .7858C.1228 1.1571 .369 .9452 .4707 .8874C.5724 .8296 1.1675 .7426 .9542 .4985C.741 .2543 .4669 -.0199 .3195 .0011C.1722 .0222 -.0768 .4145 .023 .7858Z"
		case .d:
			return "M.0424 .8656C.1582 1.2569 .2807 .6872 .4109 .5059C.5412 .3246 .8011 .3652 .9743 .2232C1.1475 .0812 .3949 -.0125 .2311 .0014C.0672 .0152 -.0733 .4742 .0424 .8656Z"
		case .e:
			return "M.5292 .0271C.7376 .0572 1.0459 .0101 .9942 .1232C.9426 .2364 .593 .2519 .3517 .3443C.2022 .4015 .0648 1.0535 .001 .9965C-.0015 .9943 .0013 .6934 .0013 .69C.001 .558 .001 .4928 .001 .2827C.001 .2765 .0174 .1298 .0177 .1232C.0234 -.043 .3207 -.0029 .5292 .0271Z"
		case .f:
			return "M.1167 .0166C.2708 .0166 1.0603 -.0431 .9963 .064C.9323 .1711 .4315 .1156 .2981 .4609C.1647 .8061 .0598 1.1142 .027 .9585C-.0058 .8027 -.0374 .0166 .1167 .0166Z"
		case .g:
			return "M.9776 .0102C.9021 .102 .7025 .4454 .5385 .4568C.5356 .457 .0886 .4782 .0858 .4786C.0158 .4862 .0235 .5989 .1087 .8168C.0362 .9392 0 1.0003 0 1C0 .9997 .0824 .9527 .2472 .8589L.8747 .65C.9936 .1623 1.0279 -.0509 .9776 .0102Z"
		case .h:
			return "M.838 .0171C.7667 -.1075 .7893 .4876 .6225 .5492C.6176 .551 .0558 .731 .0514 .7321C-.0541 .7572 .0028 .8317 .222 .9557L.3469 .9981L.5834 1L1 .6552C.9409 .3153 .8869 .1026 .838 .0171Z"
		case .i:
			return "M.7622 .0007C.6797 -.0213 .7713 .4625 .6605 .5245C.5866 .5658 .3664 .5907 0 .599C.0212 .8419 .0317 .9633 .0316 .9631C.0315 .9629 .0899 .9752 .2068 1L1 .7246C.8965 .2567 .8172 .0154 .7622 .0007Z"
		}
	}

	// MARK: - Functions
	/// Returns the outline of the shape stretched over the given rectangle.
	///
	/// - Parameter rect: The rectangle the shape fills.
	///
	/// - Returns: The outline of the shape.
	func path(in rect: CGRect) -> CGPath {
		let path = CGMutablePath()
		let point: (CGFloat, CGFloat) -> CGPoint = { x, y in
			CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
		}
		var command: Character = "M"
		var numbers: [CGFloat] = []

		func flush() {
			switch command {
			case "M":
				guard numbers.count >= 2 else { return }
				path.move(to: point(numbers[0], numbers[1]))
				command = "L"
				numbers.removeFirst(2)
				flush()
			case "L":
				while numbers.count >= 2 {
					path.addLine(to: point(numbers[0], numbers[1]))
					numbers.removeFirst(2)
				}
			case "C":
				while numbers.count >= 6 {
					path.addCurve(to: point(numbers[4], numbers[5]), control1: point(numbers[0], numbers[1]), control2: point(numbers[2], numbers[3]))
					numbers.removeFirst(6)
				}
			case "Z":
				path.closeSubpath()
				numbers.removeAll()
			default:
				numbers.removeAll()
			}
		}

		var token = ""

		func appendToken() {
			guard let number = Double(token) else {
				token = ""
				return
			}
			numbers.append(CGFloat(number))
			token = ""
		}

		for character in self.pathData {
			switch character {
			case "M", "L", "C", "Z":
				appendToken()
				flush()
				command = character
				if character == "Z" {
					flush()
				}
			case " ", ",":
				appendToken()
			case "-":
				appendToken()
				token = "-"
			case ".":
				if token.contains(".") {
					appendToken()
				}
				token.append(character)
			default:
				token.append(character)
			}
		}

		appendToken()
		flush()

		return path
	}
}
