//
//  TrackerStore.swift
//  Tracker
//


import CoreData
import UIKit

final class TrackerStore: NSObject {
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

	var onDidUpdate: (() -> Void)?

	private let coreDataStack: CoreDataStack
	private let categoryStore: TrackerCategoryStore

	private lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
		let request = NSFetchRequest<NSManagedObject>(entityName: TrackerEntity.name)
		request.sortDescriptors = [
			NSSortDescriptor(key: TrackerEntity.createdAt, ascending: true),
			NSSortDescriptor(key: TrackerEntity.title, ascending: true)
		]
		return NSFetchedResultsController(
			fetchRequest: request,
			managedObjectContext: coreDataStack.viewContext,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
	}()

	init(coreDataStack: CoreDataStack, categoryStore: TrackerCategoryStore) {
		self.coreDataStack = coreDataStack
		self.categoryStore = categoryStore
		super.init()
		bindCategoryStore()
		configureFetchedResultsController()
	}

	convenience init(coreDataStack: CoreDataStack) {
		self.init(coreDataStack: coreDataStack, categoryStore: TrackerCategoryStore(coreDataStack: coreDataStack))
	}

	func fetchAll() -> [TrackerCategory] {
		categoryStore.fetchAllCategoryObjects().map { categoryObject in
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

	private func bindCategoryStore() {
		categoryStore.onDidUpdate = { [weak self] in
			self?.onDidUpdate?()
		}
	}

	private func configureFetchedResultsController() {
		fetchedResultsController.delegate = self
		do {
			try fetchedResultsController.performFetch()
		} catch {
			assertionFailure("Failed to fetch trackers: \(error)")
		}
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

		let scheduleValue = trackerObject.value(forKey: TrackerEntity.schedule)
		let weekdays: [Weekday]
		if let array = scheduleValue as? [Weekday] {
			weekdays = array
		} else if let set = scheduleValue as? Set<Weekday> {
			weekdays = Array(set)
		} else {
			weekdays = []
		}

		return Tracker(
			id: id,
			title: title,
			emoji: emoji,
			color: color,
			schedule: Set(weekdays),
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

extension TrackerStore: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
		onDidUpdate?()
	}
}
