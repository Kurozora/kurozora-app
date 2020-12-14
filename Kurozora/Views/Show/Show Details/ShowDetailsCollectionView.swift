//
//  ShowDetailsCollectionView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import SwiftUI

// A SwiftUI wrapper for Cosmos view
struct MyCosmosView: UIViewRepresentable {
	var rating: Double
	var starSize: Double

	func makeUIView(context: Context) -> KCosmosView {
		KCosmosView()
	}

	func updateUIView(_ uiView: KCosmosView, context: Context) {
		uiView.rating = rating

		// Autoresize Cosmos view according to it intrinsic size
		uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
		uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

		// Change Cosmos view settings here
		uiView.settings.starSize = starSize
	}
}

struct ShowDetailsCollectionView: View {
	@State var rating = 3.0

	private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
		geometry.frame(in: .global).minY
	}

	private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
		let offset = getScrollOffset(geometry)

		if offset > 0 {
			return -offset
		}

		return 0
	}

	private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
		let offset = getScrollOffset(geometry)
		let imageHeight = geometry.size.height

		if offset > 0 {
			return imageHeight + offset
		}

		return imageHeight
	}

	private func getImageHeight() -> CGFloat {
		UIScreen.main.bounds.height * 0.33
	}

	var body: some View {
		ScrollView(.vertical, showsIndicators: true) {
			GeometryReader { geometry in
				Image("Placeholders/Show Banner")
					.resizable()
					.scaledToFill()
					.frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
					.clipped()
					.offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
			}.frame(height: self.getImageHeight())

			VStack(alignment: .leading, spacing: 10) {
				HStack {
					Image("Placeholders/Show Poster")
						.resizable()
						.scaledToFill()
						.frame(width: 86, height: 128)
						.clipShape(RoundedRectangle(cornerRadius: 10))
						.shadow(color: .init(.brown), radius: 4, x: 0.0, y: 0.0)

					VStack(alignment: .leading) {
						Text("Article Written By")
							.font(.subheadline)
							.foregroundColor(.gray)
						Text("Brandon Baars")
							.font(.headline)
					}
				}

				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						Group {
							VStack {
								MyCosmosView(rating: rating, starSize: 20.0)
								Text("100 Reviews")
									.font(.subheadline)
									.fixedSize(horizontal: true, vertical: false)
							}
							Divider()
						}
						Group {
							VStack {
								Text("7+")
									.font(.headline)
								Text("Age")
									.font(.subheadline)
							}
							Divider()
						}
						Group {
							VStack {
								Image(systemName: "a.square")
									.font(.headline)
								Text("Studio")
									.font(.subheadline)
							}
							Divider()
						}
						Group {
							VStack {
								Text("7")
									.font(.headline)
								Text("100 Reviews")
									.font(.subheadline)
							}
							Divider()
						}
						Group {
							VStack {
								Text("7")
									.font(.headline)
								Text("100 Reviews")
									.font(.subheadline)
							}
							Divider()
						}
						Group {
							VStack {
								Text("7")
									.font(.headline)
								Text("100 Reviews")
									.font(.subheadline)
							}
							Divider()
						}
						Group {
							VStack {
								Text("7")
									.font(.headline)
								Text("100 Reviews")
									.font(.subheadline)
							}
							Divider()
						}
						Group {
							VStack {
								Text("7")
									.font(.headline)
								Text("100 Reviews")
									.font(.subheadline)
							}
							Divider()
						}
						Group {
							VStack {
								Text("7")
									.font(.headline)
								Text("100 Reviews")
									.font(.subheadline)
							}
							Divider()
						}
						Group {
							VStack {
								Text("7")
									.font(.headline)
								Text("100 Reviews")
									.font(.subheadline)
							}
						}
					}
				}.fixedSize(horizontal: false, vertical: true)

				Text("02 January 2019 • 5 min read")
					.font(.system(size: 12))
					.foregroundColor(.gray)

				Text("How to build a parallax scroll view")
					.font(.system(size: 28))

				Text(self.loremIpsum)
					.lineLimit(nil)
					.font(.system(size: 17))
			}.padding(.horizontal)
		}.edgesIgnoringSafeArea(.all)
	}

	let loremIpsum = """
	Lorem ipsum dolor sit amet consectetur adipiscing elit donec, gravida commodo hac non mattis augue duis vitae inceptos, laoreet taciti at vehicula cum arcu dictum. Cras netus vivamus sociis pulvinar est erat, quisque imperdiet velit a justo maecenas, pretium gravida ut himenaeos nam. Tellus quis libero sociis class nec hendrerit, id proin facilisis praesent bibendum vehicula tristique, fringilla augue vitae primis turpis. Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean....

	Lorem ipsum dolor sit amet consectetur adipiscing elit donec, gravida commodo hac non mattis augue duis vitae inceptos, laoreet taciti at vehicula cum arcu dictum. Cras netus vivamus sociis pulvinar est erat, quisque imperdiet velit a justo maecenas, pretium gravida ut himenaeos nam. Tellus quis libero sociis class nec hendrerit, id proin facilisis praesent bibendum vehicula tristique, fringilla augue vitae primis turpis. Sagittis vivamus sem morbi nam mattis phasellus vehicula facilisis suscipit posuere metus, iaculis vestibulum viverra nisl ullamcorper lectus curabitur himenaeos dictumst malesuada tempor, cras maecenas enim est eu turpis hac sociosqu tellus magnis. Sociosqu varius feugiat volutpat justo fames magna malesuada, viverra neque nibh parturient eu nascetur, cursus sollicitudin placerat lobortis nunc imperdiet. Leo lectus euismod morbi placerat pretium aliquet ultricies metus, augue turpis vulputa te dictumst mattis egestas laoreet, cubilia habitant magnis lacinia vivamus etiam aenean....
	"""
}

struct ShowDetailsCollectionView_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			ShowDetailsCollectionView()
			ShowDetailsCollectionView()
				.previewDevice("iPhone 8")
			ShowDetailsCollectionView()
				.previewDevice("iPad (8th generation)")

			ShowDetailsCollectionView()
				.previewDevice("iPad Pro (12.9-inch) (4th generation)")
		}
    }
}
