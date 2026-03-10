//
//  UIViewExtensions.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 13.01.26.
//
//

import UIKit

extension UIView {
	func addSubviews(_
					 subviews: [UIView]) {
		subviews.forEach { addSubview($0) }
	}
}

extension UIView {
	@discardableResult func edgesToSuperview() -> Self {
		guard let superview = superview else {
			fatalError("View не в иерархии!")
		}
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			topAnchor.constraint(equalTo: superview.topAnchor),
			leadingAnchor.constraint(equalTo: superview.leadingAnchor),
			trailingAnchor.constraint(equalTo: superview.trailingAnchor),
			bottomAnchor.constraint(equalTo: superview.bottomAnchor)
		])
		return self
	}
}
