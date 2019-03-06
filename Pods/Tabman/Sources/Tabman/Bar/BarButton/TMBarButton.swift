//
//  TMBarButton.swift
//  Tabman
//
//  Created by Merrick Sapsford on 06/06/2018.
//  Copyright © 2019 UI At Six. All rights reserved.
//

import UIKit

/// A button that appears in a bar and provides the interaction for initiating a page index update.
open class TMBarButton: UIControl {
    
    // MARK: Types
    
    public enum SelectionState {
        case unselected
        case partial(delta: CGFloat)
        case selected
    }
    
    // MARK: Properties
    
    /// Bar Item that is associated with the button.
    public let item: TMBarItemable
    private weak var intrinsicSuperview: UIView?
    
    private let contentView = UIView()
    private var contentViewLeading: NSLayoutConstraint!
    private var contentViewTop: NSLayoutConstraint!
    private var contentViewTrailing: NSLayoutConstraint!
    private var contentViewBottom: NSLayoutConstraint!

    // MARK: Components
    
    /// Background view.
    public let backgroundView = TMBarBackgroundView()
    
    // MARK: Customization
    
    /// Content inset of the button contents.
    open var contentInset: UIEdgeInsets = .zero {
        didSet {
            contentViewLeading.constant = contentInset.left
            contentViewTop.constant = contentInset.top
            contentViewTrailing.constant = contentInset.right
            contentViewBottom.constant = contentInset.bottom
            
            intrinsicSuperview?.setNeedsLayout()
        }
    }
    
    // MARK: State
    
    /// Selection state of the button.
    ///
    /// - unselected: Unselected - Current page index is not currently mapped to the button.
    /// - partial: Partially selected - Current page index is either arriving or departing from the mapped button.
    /// - selected: Selected - Current page index is mapped to the button.
    public var selectionState: SelectionState = .unselected {
        didSet {
            self.isSelected = selectionState == .selected
            update(for: selectionState)
        }
    }
    
    // MARK: Init
    
    /// Initialize a bar button.
    ///
    /// - Parameters:
    ///   - item: Item to create the bar button for.
    ///   - intrinsicSuperview: View that can be notified whenever any intrinsic layout changes occur.
    public required init(for item: TMBarItemable, intrinsicSuperview: UIView?) {
        self.item = item
        self.intrinsicSuperview = intrinsicSuperview
        super.init(frame: .zero)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported - Use init(for item)")
    }
    
    private func initialize() {
        
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        contentView.isUserInteractionEnabled = false
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewLeading = contentView.leadingAnchor.constraint(equalTo: leadingAnchor)
        contentViewTop = contentView.topAnchor.constraint(equalTo: topAnchor)
        contentViewTrailing = trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        contentViewBottom = bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        NSLayoutConstraint.activate([contentViewLeading, contentViewTop, contentViewTrailing, contentViewBottom])
        
        layout(in: contentView)
    }
    
    // MARK: Lifecycle
    
    open func layout(in view: UIView) {
    }
    
    open func populate(for item: TMBarItemable) {
    }
    
    open func update(for selectionState: SelectionState) {
        let minimumAlpha: CGFloat = 0.5
        let alpha = minimumAlpha + (selectionState.rawValue * minimumAlpha)
        
        self.alpha = alpha
    }
}

extension TMBarButton.SelectionState: Equatable {
    
    public static func from(rawValue: CGFloat) -> TMBarButton.SelectionState {
        switch rawValue {
        case 0.0:
            return .unselected
        case 1.0:
            return .selected
        default:
            return .partial(delta: rawValue)
        }
    }
    
    public var rawValue: CGFloat {
        switch self {
        case .unselected:
            return 0.0
        case .partial(let delta):
            return delta
        case .selected:
            return 1.0
        }
    }
    
    public static func == (lhs: TMBarButton.SelectionState, rhs: TMBarButton.SelectionState) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
