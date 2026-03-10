//
//  AppDependencyContainer.swift
//  Tracker
//

import Foundation

final class AppDependencyContainer {
	let coreDataStack: CoreDataStack

	lazy var trackerCategoryStore = TrackerCategoryStore(coreDataStack: coreDataStack)
	lazy var trackerStore = TrackerStore(
		coreDataStack: coreDataStack,
		categoryStore: trackerCategoryStore
	)
	lazy var trackerRecordStore = TrackerRecordStore(coreDataStack: coreDataStack)

	init(coreDataStack: CoreDataStack) {
		self.coreDataStack = coreDataStack
	}
}
