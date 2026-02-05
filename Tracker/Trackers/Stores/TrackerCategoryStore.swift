//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 05.02.26.
//

import CoreData

final class TrackerCategoryStore {
	private enum Constants {
		static let entityName = "TrackerCategoryCoreData"
		static let titleKey = "title"
	}

	private let coreDataStack: CoreDataStack

	init(coreDataStack: CoreDataStack) {
		self.coreDataStack = coreDataStack
	}

	func fetchAllCategoryObjects() throws -> [NSManagedObject] {
		let request = NSFetchRequest<NSManagedObject>(entityName: Constants.entityName)
		request.sortDescriptors = [NSSortDescriptor(key: Constants.titleKey, ascending: true)]
		return try coreDataStack.viewContext.fetch(request)
	}

	func fetchOrCreateCategory(withTitle title: String) throws -> NSManagedObject {
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
}
