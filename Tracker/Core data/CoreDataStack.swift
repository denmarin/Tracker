//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 04.02.26.
//

import CoreData

final class CoreDataStack {
	private let modelName: String
	private(set) lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: modelName)
		return container
	}()
	var viewContext: NSManagedObjectContext {
		persistentContainer.viewContext
	}

	init(modelName: String = "Tracker") {
		self.modelName = modelName
		CoreDataTransformers.register()
	}

	func load() {
		persistentContainer.loadPersistentStores { _, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
	}

	func saveContext() {
		let context = persistentContainer.viewContext
		guard context.hasChanges else { return }
		do {
			try context.save()
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
}
