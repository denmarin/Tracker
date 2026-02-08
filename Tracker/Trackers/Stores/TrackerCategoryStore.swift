//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 05.02.26.
//

import CoreData

final class TrackerCategoryStore: NSObject {
	private enum Constants {
		static let entityName = "TrackerCategoryCoreData"
		static let titleKey = "title"
	}

	var onDidUpdate: (() -> Void)?

	private let coreDataStack: CoreDataStack

	private lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
		let request = NSFetchRequest<NSManagedObject>(entityName: Constants.entityName)
		request.sortDescriptors = [NSSortDescriptor(key: Constants.titleKey, ascending: true)]
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

	func fetchAllCategoryObjects() -> [NSManagedObject] {
		fetchedResultsController.fetchedObjects ?? []
	}

	func fetchOrCreateCategory(withTitle title: String) throws -> NSManagedObject {
		if let category = fetchAllCategoryObjects().first(where: { object in
			(object.value(forKey: Constants.titleKey) as? String) == title
		}) {
			return category
		}

		let context = coreDataStack.viewContext
		let request = NSFetchRequest<NSManagedObject>(entityName: Constants.entityName)
		request.fetchLimit = 1
		request.predicate = NSPredicate(format: "%K == %@", Constants.titleKey, title)

		if let existing = try context.fetch(request).first {
			return existing
		}

		let category = NSEntityDescription.insertNewObject(forEntityName: Constants.entityName, into: context)
		category.setValue(title, forKey: Constants.titleKey)
		return category
	}

	private func configureFetchedResultsController() {
		fetchedResultsController.delegate = self
		do {
			try fetchedResultsController.performFetch()
		} catch {
			assertionFailure("Failed to fetch categories: \(error)")
		}
	}
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
		onDidUpdate?()
	}
}
