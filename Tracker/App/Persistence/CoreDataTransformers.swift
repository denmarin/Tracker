//
//  CoreDataTransformers.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 04.02.26.
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
