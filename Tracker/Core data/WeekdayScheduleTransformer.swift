//
//  WeekdayScheduleTransformer.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 08.02.26.
//

import UIKit

final class WeekdayScheduleTransformer: ValueTransformer {
	static let name = NSValueTransformerName("WeekdayScheduleTransformer")

	override class func transformedValueClass() -> AnyClass {
		NSData.self
	}

	override class func allowsReverseTransformation() -> Bool {
		true
	}

	override func transformedValue(_ value: Any?) -> Any? {
		if let weekdays = value as? [Weekday] {
			return encode(weekdays)
		}
		if let weekdaySet = value as? Set<Weekday> {
			return encode(Array(weekdaySet))
		}
		return nil
	}

	override func reverseTransformedValue(_ value: Any?) -> Any? {
		guard let data = value as? Data else { return nil }
		let ints = (try? JSONDecoder().decode([Int].self, from: data)) ?? []
		return ints.compactMap { Weekday(rawValue: $0) }
	}

	private func encode(_ weekdays: [Weekday]) -> Data? {
		let ints = weekdays.map { $0.rawValue }
		return try? JSONEncoder().encode(ints)
	}
}
