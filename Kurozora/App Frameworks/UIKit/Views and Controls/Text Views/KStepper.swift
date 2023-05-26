//
//  KStepper.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

protocol KStepperDelegate: AnyObject {
	func kStepper(_ stepper: KStepper, valueChanged value: Double)
}

/// A control for incrementing or decrementing a value.
///
/// By default, pressing and holding a stepper’s button increments or decrements the stepper’s value repeatedly. The rate of change depends on how long the user continues pressing the control. To turn off this behavior, set the [autorepeat](x-source-tag://KStepper-autorepeat) property to `false`.
///
/// The maximum value must be greater than or equal to the minimum value. If you set a maximum or minimum value that would break this invariant, both values are set to the new value. For example, if the minimum value is 200 and you set a maximum value of 100, then both the minimum and maximum become 200.
///
/// - Tag: KStepper
@IBDesignable
@MainActor open class KStepper: UIControl {
	// MARK: - Views
	private let backgroundButton: UIButton = UIButton(type: .system)
	private let decrementButton: UIButton = UIButton(type: .system)
	private let incrementButton: UIButton = UIButton(type: .system)
	private let valueTextField: UITextField = UITextField()

	// MARK: - Properties
	weak var delegate: KStepperDelegate?

	/// A Boolean value that determines whether to send value changes during user interaction or after user interaction ends.
	///
	/// If `true`, the stepper sends value change events immediately as the value changes during user interaction. If `false`, the stepper sends a value change event after user interaction ends.
	///
	/// The default value for this property is `true`.
	///
	/// - Tag: KStepper-isContinuous
	@IBInspectable open var isContinuous: Bool = true

	/// A Boolean value that determines whether to repeatedly change the stepper’s value as the user presses and holds a stepper button.
	///
	/// If `true`, the user pressing and holding on the stepper repeatedly alters [value](x-source-tag://KStepper-value).
	///
	/// The default value for this property is `true`.
	///
	/// - Tag: KStepper-autorepeat
	@IBInspectable open var autorepeat: Bool = true

	/// A Boolean value that determines whether the stepper can wrap its value to the minimum or maximum value when incrementing and decrementing the value.
	///
	/// If `true`, incrementing beyond [maximumValue](x-source-tag://KStepper-maximumValue) sets [value](x-source-tag://KStepper-value) to [minimumValue](x-source-tag://KStepper-minimumValue); likewise, decrementing below minimumValue sets [value](x-source-tag://KStepper-value) to maximumValue. If false, the stepper doesn’t increment beyond maximumValue nor does it decrement below minimumValue but rather holds at those values.
	///
	/// The default value for this property is `false`.
	///
	/// - Tag: KStepper-wraps
	@IBInspectable open var wraps: Bool = false

	/// The numeric value of the stepper.
	///
	/// When the value changes, the stepper sends the [valueChanged](x-source-tag://KStepper-valueChanged) flag to its target (see [addTarget(_:action:for:)](https://developer.apple.com/documentation/uikit/uicontrol/1618259-addtarget)). Refer to the description of the [isContinuous](x-source-tag://KStepper-isContinuous) property for information about whether value change events are sent continuously or when user interaction ends.
	///
	/// The default value for this property is `0`. This property is clamped at its lower extreme to [minimumValue](x-source-tag://KStepper-minimumValue) and is clamped at its upper extreme to [maximumValue](x-source-tag://KStepper-maximumValue).
	///
	/// - Tag: KStepper-value
	@IBInspectable open var value: Double = 0.0 {
		didSet {
			if self.value > self.maximumValue {
				self.maximumValue = self.value
			} else if self.value < self.minimumValue {
				self.minimumValue = self.value
			} else {
				self.updateValueTextField()
			}

			if self.isContinuous {
				self.sendActions(for: .valueChanged)
			}
		}
	}

	/// The lowest possible numeric value for the stepper.
	///
	/// Must be numerically less than [maximumValue](x-source-tag://KStepper-maximumValue). If you attempt to set a value equal to or greater than `maximumValue`, the system raises an [invalidArgumentException](https://developer.apple.com/documentation/foundation/nsexceptionname/1415426-invalidargumentexception) exception.
	///
	/// The default value for this property is `0`.
	///
	/// - Tag: KStepper-minimumValue
	@IBInspectable open var minimumValue: Double = 0.0 {
		didSet {
			if self.minimumValue >= self.maximumValue {
				#if TARGET_INTERFACE_BUILDER
				self.maximumValue = self.minimumValue
				#else
				NSException(name: .invalidArgumentException, reason: "minimumValue cannot be equal to or greater than `maximumValue`").raise()
				#endif
			} else {
				self.updateValueIfNeeded()
			}
		}
	}

	/// The highest possible numeric value for the stepper.
	///
	/// Must be numerically greater than [minimumValue](x-source-tag://KStepper-minimumValue). If you attempt to set a value equal to or lower than `minimumValue`, the system raises an [invalidArgumentException](https://developer.apple.com/documentation/foundation/nsexceptionname/1415426-invalidargumentexception) exception.
	///
	/// The default value of this property is `100`.
	///
	/// - Tag: KStepper-maximumValue
	@IBInspectable open var maximumValue: Double = 100.0 {
		didSet {
			if self.maximumValue <= self.minimumValue {
				#if TARGET_INTERFACE_BUILDER
				self.minimumValue = self.maximumValue
				#else
				NSException(name: .invalidArgumentException, reason: "maximumValue cannot be equal to or lower than `minimumValue`").raise()
				#endif
			} else {
				self.updateValueIfNeeded()
			}
		}
	}

	/// The step, or increment, value for the stepper.
	///
	/// Must be numerically greater than `0`. If you attempt to set this property’s value to `0` or to a negative number, the system raises an [invalidArgumentException](https://developer.apple.com/documentation/foundation/nsexceptionname/1415426-invalidargumentexception) exception.
	///
	/// The default value for this property is `1`.
	///
	/// - Tag: KStepper-stepValue
	@IBInspectable
	open var stepValue: Double = 1.0 {
		didSet {
			if self.stepValue <= 0 {
				#if TARGET_INTERFACE_BUILDER
				self.stepValue = 1.0
				#else
				NSException(name: .invalidArgumentException, reason: "stepValue cannot be 0 or a negative number").raise()
				#endif
			} else {
				self.updateValueIfNeeded()
			}
		}
	}

	private var repeatTimer: Timer?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configure()
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configure()
	}

	open override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		self.updateValueTextField()
	}

	open override func awakeFromNib() {
		super.awakeFromNib()
		self.updateValueTextField()
	}
}

// MARK: - Configure View
extension KStepper {
	private func configure() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()

		self.updateValueTextField()
		self.updateButtonEnabledState()
	}

	func configureViews() {
		self.configureBackgroundButton()
		self.configureDecrementButton()
		self.configureValueTextField()
		self.configureIncrementButton()
	}

	func configureBackgroundButton() {
		var configuration = UIButton.Configuration.gray()
		configuration.background = .listSidebarCell()

		self.backgroundButton.translatesAutoresizingMaskIntoConstraints = false
		self.backgroundButton.isUserInteractionEnabled = false
		self.backgroundButton.configuration = configuration
	}

	func configureDecrementButton() {
		let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body, scale: .medium)

		self.decrementButton.translatesAutoresizingMaskIntoConstraints = false
		self.decrementButton.setImage(UIImage(systemName: "minus", withConfiguration: symbolConfiguration), for: .normal)
		self.decrementButton.theme_tintColor = KThemePicker.textColor.rawValue

		self.decrementButton.addTarget(self, action: #selector(self.handleDecrementButtonTouchDown), for: .touchDown)
		self.decrementButton.addTarget(self, action: #selector(self.handleDecrementButtonTouchUp), for: .touchUpInside)
		self.decrementButton.addTarget(self, action: #selector(self.handleDecrementButtonTouchUp), for: .touchUpOutside)
		self.decrementButton.addTarget(self, action: #selector(self.handleDecrementButtonTouchUp), for: .touchDragExit)
		self.decrementButton.addTarget(self, action: #selector(self.handleDecrementButtonTouchUp), for: .touchCancel)
	}

	func configureValueTextField() {
		self.valueTextField.translatesAutoresizingMaskIntoConstraints = false
		self.valueTextField.borderStyle = .none
		self.valueTextField.keyboardType = .numberPad
		self.valueTextField.textAlignment = .center
		self.valueTextField.font = .preferredFont(forTextStyle: .body)
		self.valueTextField.backgroundColor = .clear
		self.valueTextField.theme_tintColor = KThemePicker.tintColor.rawValue
		self.valueTextField.theme_textColor = KThemePicker.textColor.rawValue

		self.valueTextField.addTarget(self, action: #selector(self.handleValueTextFieldChanged), for: .editingChanged)
	}

	func configureIncrementButton() {
		let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body, scale: .medium)

		self.incrementButton.translatesAutoresizingMaskIntoConstraints = false
		self.incrementButton.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfiguration), for: .normal)
		self.incrementButton.theme_tintColor = KThemePicker.textColor.rawValue

		self.incrementButton.addTarget(self, action: #selector(self.handleIncrementButtonTouchDown), for: .touchDown)
		self.incrementButton.addTarget(self, action: #selector(self.handleIncrementButtonTouchUp), for: .touchUpInside)
		self.incrementButton.addTarget(self, action: #selector(self.handleIncrementButtonTouchUp), for: .touchUpOutside)
		self.incrementButton.addTarget(self, action: #selector(self.handleIncrementButtonTouchUp), for: .touchDragExit)
		self.incrementButton.addTarget(self, action: #selector(self.handleIncrementButtonTouchUp), for: .touchCancel)
	}
}

// MARK: - View Hierarchy
private extension KStepper {
	func configureViewHierarchy() {
		self.addSubview(self.backgroundButton)
		self.addSubview(self.decrementButton)
		self.addSubview(self.incrementButton)
		self.addSubview(self.valueTextField)
	}
}

// MARK: - View Constraints
private extension KStepper {
	func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.backgroundButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.backgroundButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.backgroundButton.topAnchor.constraint(equalTo: self.topAnchor),
			self.backgroundButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.decrementButton.heightAnchor.constraint(equalToConstant: 38.0),

			self.decrementButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.decrementButton.topAnchor.constraint(equalTo: self.topAnchor),
			self.decrementButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.decrementButton.widthAnchor.constraint(equalToConstant: 44.0),

			self.valueTextField.leadingAnchor.constraint(equalTo: self.decrementButton.trailingAnchor),
			self.valueTextField.trailingAnchor.constraint(equalTo: self.incrementButton.leadingAnchor),
			self.valueTextField.topAnchor.constraint(equalTo: self.topAnchor),
			self.valueTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			self.incrementButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.incrementButton.topAnchor.constraint(equalTo: self.topAnchor),
			self.incrementButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.incrementButton.widthAnchor.constraint(equalToConstant: 44.0)
		])
	}
}

// MARK: - Handlers
private extension KStepper {
	@objc func handleDecrementButtonTouchUp() {
		self.stopRepeatTimer()

		if !self.isContinuous {
			self.sendActions(for: .valueChanged)
		}
	}

	@objc func handleDecrementButtonTouchDown() {
		self.decrementValue()

		if self.autorepeat {
			self.startRepeatTimer(for: #selector(self.decrementValue))
		}
	}

	@objc func handleIncrementButtonTouchUp() {
		self.stopRepeatTimer()

		if !self.isContinuous {
			self.sendActions(for: .valueChanged)
		}
	}

	@objc func handleIncrementButtonTouchDown() {
		self.incrementValue()

		if self.autorepeat {
			self.startRepeatTimer(for: #selector(self.incrementValue))
		}
	}

	@objc func handleValueTextFieldChanged() {
		guard let text = self.valueTextField.text, let newValue = Double(text) else { return }
		guard newValue >= self.minimumValue else {
			self.value = self.minimumValue
			self.updateButtonEnabledState()
			return
		}
		guard newValue <= self.maximumValue else {
			self.value = self.maximumValue
			self.updateButtonEnabledState()
			return
		}

		self.value = newValue
		self.updateButtonEnabledState()
	}

	func updateValueTextField() {
		self.valueTextField.text = self.value.withoutTrailingZeros
	}

	func updateButtonEnabledState() {
		self.decrementButton.isEnabled = self.value > self.minimumValue
		self.incrementButton.isEnabled = self.value < self.maximumValue
	}

	func updateValueIfNeeded() {
		if self.value < self.minimumValue {
			self.value = self.minimumValue
		} else if self.value > self.maximumValue {
			self.value = self.maximumValue
		}

		self.updateButtonEnabledState()
	}

	@objc func decrementValue() {
		if self.value - self.stepValue >= self.minimumValue {
			self.value -= self.stepValue
			self.delegate?.kStepper(self, valueChanged: self.value)
		} else if self.wraps {
			self.value = self.maximumValue
			self.delegate?.kStepper(self, valueChanged: self.value)
		}

		self.updateButtonEnabledState()
	}

	@objc func incrementValue() {
		if self.value + self.stepValue <= self.maximumValue {
			self.value += self.stepValue
			self.delegate?.kStepper(self, valueChanged: self.value)
		} else if self.wraps {
			self.value = self.minimumValue
			self.delegate?.kStepper(self, valueChanged: self.value)
		}

		self.updateButtonEnabledState()
	}
}

// MARK: - Repeat Timer
private extension KStepper {
	func startRepeatTimer(for selector: Selector) {
		self.stopRepeatTimer()
		self.repeatTimer = Timer.scheduledTimer(
			timeInterval: 0.1,
			target: self,
			selector: selector,
			userInfo: nil,
			repeats: true
		)
	}

	func stopRepeatTimer() {
		self.repeatTimer?.invalidate()
		self.repeatTimer = nil
	}
}
