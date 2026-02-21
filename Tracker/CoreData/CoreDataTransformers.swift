//
//  CoreDataTransformers.swift
//  Tracker
//


import UIKit

enum CoreDataTransformers {
	static func register() {
		ValueTransformer.setValueTransformer(
			UIColorTransformer(),
			forName: UIColorTransformer.name
		)
		ValueTransformer.setValueTransformer(
			WeekdayScheduleTransformer(),
			forName: WeekdayScheduleTransformer.name
		)
	}
}
