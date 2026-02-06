//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 05.02.26.
//

import CoreData

final class TrackerRecordStore: NSObject {
	enum StoreError: Error {
		case trackerNotFound(UUID)
	}

	private enum TrackerEntity {
		static let name = "TrackerCoreData"
		static let id = "id"
	}

	private enum RecordEntity {
		static let name = "TrackerRecordCoreData"
		static let date = "date"
		static let tracker = "tracker"
	}

	var onDidUpdate: (() -> Void)?

	private let coreDataStack: CoreDataStack

	private lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
		let request = NSFetchRequest<NSManagedObject>(entityName: RecordEntity.name)
		request.sortDescriptors = [NSSortDescriptor(key: RecordEntity.date, ascending: false)]
		return NSFetchedResultsController(
			fetchRequest: request,
			managedObjectContext: coreDataStack.viewContext,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
	}()

	init(coreDataStack: CoreDataStack) {
		self.coreDataStack = coreDataStack
		super.init()
		configureFetchedResultsController()
	}

	func fetchAll() -> [TrackerRecord] {
		(fetchedResultsController.fetchedObjects ?? []).compactMap { object in
			guard
				let trackerObject = object.value(forKey: RecordEntity.tracker) as? NSManagedObject,
				let trackerID = trackerObject.value(forKey: TrackerEntity.id) as? UUID,
				let date = object.value(forKey: RecordEntity.date) as? Date
			else {
				return nil
			}
			return TrackerRecord(trackerId: trackerID, date: date)
		}
	}

	func add(_ record: TrackerRecord) throws {
		let context = coreDataStack.viewContext
		let normalizedDate = Calendar.current.startOfDay(for: record.date)

		if try fetchRecordObject(trackerID: record.trackerId, date: normalizedDate, in: context) != nil {
			return
		}

		guard let trackerObject = try fetchTrackerObject(by: record.trackerId, in: context) else {
			throw StoreError.trackerNotFound(record.trackerId)
		}

		let recordObject = NSEntityDescription.insertNewObject(forEntityName: RecordEntity.name, into: context)
		recordObject.setValue(normalizedDate, forKey: RecordEntity.date)
		recordObject.setValue(trackerObject, forKey: RecordEntity.tracker)
		coreDataStack.saveContext()
	}

	func delete(_ record: TrackerRecord) throws {
		let context = coreDataStack.viewContext
		let normalizedDate = Calendar.current.startOfDay(for: record.date)
		if let object = try fetchRecordObject(trackerID: record.trackerId, date: normalizedDate, in: context) {
			context.delete(object)
			coreDataStack.saveContext()
		}
	}

	private func configureFetchedResultsController() {
		fetchedResultsController.delegate = self
		do {
			try fetchedResultsController.performFetch()
		} catch {
			assertionFailure("Failed to fetch tracker records: \(error)")
		}
	}

	private func fetchTrackerObject(by id: UUID, in context: NSManagedObjectContext) throws -> NSManagedObject? {
		let request = NSFetchRequest<NSManagedObject>(entityName: TrackerEntity.name)
		request.fetchLimit = 1
		request.predicate = NSPredicate(format: "%K == %@", TrackerEntity.id, id as CVarArg)
		return try context.fetch(request).first
	}

	private func fetchRecordObject(trackerID: UUID, date: Date, in context: NSManagedObjectContext) throws -> NSManagedObject? {
		let request = NSFetchRequest<NSManagedObject>(entityName: RecordEntity.name)
		request.fetchLimit = 1
		request.predicate = NSPredicate(
			format: "%K.%K == %@ AND %K == %@",
			RecordEntity.tracker,
			TrackerEntity.id,
			trackerID as CVarArg,
			RecordEntity.date,
			date as CVarArg
		)
		return try context.fetch(request).first
	}
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
		onDidUpdate?()
	}
}
