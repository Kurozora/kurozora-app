//
//  UIAlertController+Extension.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIAlertController {
	static func actionSheetWithItems<A : Equatable>(items : [(title : String, value : A)], currentSelection : A? = nil, action : @escaping (A) -> Void) -> UIAlertController {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		for (var title, value) in items {
			if let selection = currentSelection, value == selection {
				// Note that checkmark and space have a neutral text flow direction so this is correct for RTL
				title = title + " ✔︎"
			}
			alertController.addAction(
				UIAlertAction(title: title, style: .default) {_ in
					action(value)
				}
			)
		}
		return alertController
	}
}

/**
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

private var defaultParentCellVerticalPadding: CGFloat = 50
private var defaultParentCellWidthHeightRatio: CGFloat = 3 / 4

public enum ChainPageCollectionViewType {
	/// customParentHeight type will splits the screen to custom ratio.
	case customParentHeight(Int, Int)

	func viewHeightRatio() -> CGFloat {
		var heightRatio = CGFloat(0)

		switch self {
		case let .customParentHeight(pInt, cInt):
			guard pInt > 0, cInt > 0 else { break }
			let total = CGFloat(pInt + cInt)
			heightRatio = CGFloat(pInt) / total
		}

		return heightRatio
	}
}

/// The view which contains chained collectionViews.
/// The change of parent view can reload its child collectionView.
class ChainPageCollectionView: UIView {

//	/// The parent collection view.
//	public var parentCollectionView: UICollectionView!
//	public var parentCollectionViewItemSize: CGSize = .zero
//
//	fileprivate var parentIndexChangeDuringFadeIn: Bool = false
//	fileprivate var lastTimeViewHeight: CGFloat = 0.0
//	fileprivate let viewType: ChainPageCollectionViewType
//
//	/// The selection index of parentCollectionView.
//	public var parentCollectionViewIndex: Int = 0 {
//		didSet {
//			if parentCollectionViewIndex == oldValue {
//				return
//			}
//		}
//	}
//
//	init(viewType: ChainPageCollectionViewType, parentCollectionViewLayout: UICollectionViewFlowLayout = BannerCollectionLayout(scaled: true)) {
//		self.viewType = viewType
//
//		parentCollectionView = UICollectionView(frame: .zero, collectionViewLayout: parentCollectionViewLayout)
//		parentCollectionView.backgroundColor = .clear
//		parentCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
//
//		super.init(frame: .zero)
//		parentCollectionView.translatesAutoresizingMaskIntoConstraints = false
//		addSubview(parentCollectionView)
//		parentCollectionView.dataSource = self
//		parentCollectionView.delegate = self
//		buildConstraints()
//	}
//
//	required init?(coder aDecoder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//
//	open override func layoutSubviews() {
//		super.layoutSubviews()
//		let viewHeight = bounds.size.height
//		if viewHeight != lastTimeViewHeight {
//			lastTimeViewHeight = bounds.size.height
//			let parentHeightRatio = viewType.viewHeightRatio()
//
//			// Adjust parentCollectionViewItemSize.
//			var validParentItemSize: CGSize = .zero
//			if (parentCollectionViewItemSize == .zero ||
//				parentCollectionViewItemSize.height > viewHeight * parentHeightRatio) {
//				let parentItemHeight = viewHeight * parentHeightRatio - 2 * defaultParentCellVerticalPadding
//				validParentItemSize = CGSize(width: parentItemHeight * defaultParentCellWidthHeightRatio, height: parentItemHeight)
//			} else {
//				// Restore user's setting. e.g: Rotate to horizontal then rotate back.
//				validParentItemSize = parentCollectionViewItemSize
//			}
//			if let parentLayout = parentCollectionView.collectionViewLayout as? BannerCollectionLayout {
//				parentLayout.itemSize = validParentItemSize
//			}
//		}
//	}
}

// MARK: - Helpers
//extension ChainPageCollectionView {
//	func buildConstraints() {
//		parentCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//		parentCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//		parentCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//		parentCollectionView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: viewType.viewHeightRatio()).isActive = true
//	}
//}

// MARK: - Protocol
// MARK: UICollectionViewDataSource, UICollectionViewDelegate

//extension ChainPageCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {

//	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//		return 10
//	}
//
//	public func numberOfSections(in collectionView: UICollectionView) -> Int {
//		return 1
//	}
//
//	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
//		return cell
//	}
//
//	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//		guard let collectionView = scrollView as? UICollectionView,
//			collectionView == parentCollectionView,
//			let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
//				return
//		}
//		let initialOffset = (collectionView.bounds.size.width - layout.itemSize.width) / 2
//		let currentItemCentralX =
//			collectionView.contentOffset.x + initialOffset + layout.itemSize.width / 2
//		let pageWidth = layout.itemSize.width + layout.minimumLineSpacing
//		parentCollectionViewIndex = Int(currentItemCentralX / pageWidth)
//	}
//}
