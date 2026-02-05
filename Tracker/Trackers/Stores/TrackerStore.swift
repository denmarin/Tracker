//
//  TrackerStore.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 05.02.26.
//

import CoreData
import UIKit

final class TrackerStore {
	private enum TrackerEntity {
		static let name = "TrackerCoreData"
		static let id = "id"
		static let title = "title"
		static let emoji = "emoji"
		static let color = "color"
		static let schedule = "schedule"
		static let createdAt = "createdAt"
		static let category = "category"
	}

	private enum CategoryEntity {
		static let title = "title"
		static let trackers = "trackers"
	}

	private let coreDataStack: CoreDataStack
	private let categoryStore: TrackerCategoryStore

	init(coreDataStack: CoreDataStack, categoryStore: TrackerCategoryStore) {
		self.coreDataStack = coreDataStack
		self.categoryStore = categoryStore
	}

	convenience init(coreDataStack: CoreDataStack) {
		self.init(coreDataStack: coreDataStack, categoryStore: TrackerCategoryStore(coreDataStack: coreDataStack))
	}

	func fetchAll() throws -> [TrackerCategory] {
		let categoryObjects = try categoryStore.fetchAllCategoryObjects()
		return categoryObjects.map { categoryObject in
			let title = (categoryObject.value(forKey: CategoryEntity.title) as? String) ?? ""
			let trackers = trackerObjects(from: categoryObject)
				.compactMap { trackerObject in
					mapTracker(from: trackerObject)
				}
				.sorted { $0.createdAt < $1.createdAt }
			return TrackerCategory(title: title, trackers: trackers)
		}
	}

	func add(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
		let context = coreDataStack.viewContext
		let categoryObject = try categoryStore.fetchOrCreateCategory(withTitle: title)
		let trackerObject = try fetchTrackerObject(by: tracker.id, in: context)
			?? NSEntityDescription.insertNewObject(forEntityName: TrackerEntity.name, into: context)

		trackerObject.setValue(tracker.id, forKey: TrackerEntity.id)
		trackerObject.setValue(tracker.title, forKey: TrackerEntity.title)
		trackerObject.setValue(tracker.emoji, forKey: TrackerEntity.emoji)
		trackerObject.setValue(tracker.color, forKey: TrackerEntity.color)
		trackerObject.setValue(Array(tracker.schedule), forKey: TrackerEntity.schedule)
		trackerObject.setValue(tracker.createdAt, forKey: TrackerEntity.createdAt)
		trackerObject.setValue(categoryObject, forKey: TrackerEntity.category)

		coreDataStack.saveContext()
	}

	private func fetchTrackerObject(by id: UUID, in context: NSManagedObjectContext) throws -> NSManagedObject? {
		let request = NSFetchRequest<NSManagedObject>(entityName: TrackerEntity.name)
		request.fetchLimit = 1
		request.predicate = NSPredicate(format: "%K == %@", TrackerEntity.id, id as CVarArg)
		return try context.fetch(request).first
	}

	private func mapTracker(from trackerObject: NSManagedObject) -> Tracker? {
		guard
			let id = trackerObject.value(forKey: TrackerEntity.id) as? UUID,
			let title = trackerObject.value(forKey: TrackerEntity.title) as? String,
			let emoji = trackerObject.value(forKey: TrackerEntity.emoji) as? String,
			let color = trackerObject.value(forKey: TrackerEntity.color) as? UIColor,
			let createdAt = trackerObject.value(forKey: TrackerEntity.createdAt) as? Date
		else {
			return nil
		}

		let scheduleArray = (trackerObject.value(forKey: TrackerEntity.schedule) as? [Weekday]) ?? []
		return Tracker(
			id: id,
			title: title,
			emoji: emoji,
			color: color,
			schedule: Set(scheduleArray),
			createdAt: createdAt
		)
	}

	private func trackerObjects(from categoryObject: NSManagedObject) -> [NSManagedObject] {
		if let nsSet = categoryObject.value(forKey: CategoryEntity.trackers) as? NSSet {
			return nsSet.compactMap { $0 as? NSManagedObject }
		}
		if let set = categoryObject.value(forKey: CategoryEntity.trackers) as? Set<NSManagedObject> {
			return Array(set)
		}
		return []
	}
}
