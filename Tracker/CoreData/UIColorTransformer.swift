//
//  UIColorTransformer.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 08.02.26.
//


import UIKit

final class UIColorTransformer: ValueTransformer {
	static let name = NSValueTransformerName("UIColorTransformer")

	override class func transformedValueClass() -> AnyClass {
		NSData.self
	}

	override class func allowsReverseTransformation() -> Bool {
		true
	}

	override func transformedValue(_ value: Any?) -> Any? {
		guard let color = value as? UIColor else { return nil }
		do {
			return try NSKeyedArchiver.archivedData(
				withRootObject: color,
				requiringSecureCoding: true
			)
		} catch {
			return nil
		}
	}

	override func reverseTransformedValue(_ value: Any?) -> Any? {
		guard let data = value as? Data else { return nil }
		return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
	}
}
