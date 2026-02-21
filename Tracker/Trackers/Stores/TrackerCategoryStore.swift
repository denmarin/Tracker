//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 05.02.26.
//

import CoreData

struct TrackerCategoryItem: Equatable {
	let objectID: NSManagedObjectID
	let title: String
}

enum TrackerCategoryStoreError: LocalizedError {
	case emptyTitle
	case duplicateTitle
	case categoryNotFound

	var errorDescription: String? {
		switch self {
		case .emptyTitle:
			return "Название категории не может быть пустым."
		case .duplicateTitle:
			return "Такая категория уже существует."
		case .categoryNotFound:
			return "Категория не найдена."
		}
	}
}

final class TrackerCategoryStore: NSObject {
	private enum Constants {
		static let entityName = "TrackerCategoryCoreData"
		static let titleKey = "title"
	}

	var onDidUpdate: (() -> Void)?

	private let coreDataStack: CoreDataStack
	private var updateObservers: [UUID: () -> Void] = [:]

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

	func fetchCategories() -> [TrackerCategoryItem] {
		fetchAllCategoryObjects().map { mapCategory(from: $0) }
	}

	func category(forTitle title: String) -> TrackerCategoryItem? {
		let normalizedTitle = normalizedCategoryTitle(title)
		guard !normalizedTitle.isEmpty else { return nil }
		guard let categoryObject = fetchCategoryObject(withTitle: normalizedTitle) else { return nil }
		return mapCategory(from: categoryObject)
	}

	func createCategory(title: String) throws -> TrackerCategoryItem {
		let normalizedTitle = normalizedCategoryTitle(title)
		guard !normalizedTitle.isEmpty else {
			throw TrackerCategoryStoreError.emptyTitle
		}
		guard fetchCategoryObject(withTitle: normalizedTitle) == nil else {
			throw TrackerCategoryStoreError.duplicateTitle
		}

		let context = coreDataStack.viewContext
		let categoryObject = NSEntityDescription.insertNewObject(forEntityName: Constants.entityName, into: context)
		categoryObject.setValue(normalizedTitle, forKey: Constants.titleKey)
		try saveContextIfNeeded()
		return mapCategory(from: categoryObject)
	}

	func updateCategory(with objectID: NSManagedObjectID, newTitle: String) throws {
		let normalizedTitle = normalizedCategoryTitle(newTitle)
		guard !normalizedTitle.isEmpty else {
			throw TrackerCategoryStoreError.emptyTitle
		}

		let context = coreDataStack.viewContext
		guard let managedObject = try? context.existingObject(with: objectID) else {
			throw TrackerCategoryStoreError.categoryNotFound
		}

		if
			let duplicate = fetchCategoryObject(withTitle: normalizedTitle),
			duplicate.objectID != objectID
		{
			throw TrackerCategoryStoreError.duplicateTitle
		}

		managedObject.setValue(normalizedTitle, forKey: Constants.titleKey)
		try saveContextIfNeeded()
	}

	func deleteCategory(with objectID: NSManagedObjectID) throws {
		let context = coreDataStack.viewContext
		guard let categoryObject = try? context.existingObject(with: objectID) else {
			throw TrackerCategoryStoreError.categoryNotFound
		}

		context.delete(categoryObject)
		try saveContextIfNeeded()
	}

	@discardableResult
	func addUpdateObserver(_ observer: @escaping () -> Void) -> UUID {
		let token = UUID()
		updateObservers[token] = observer
		return token
	}

	func removeUpdateObserver(_ token: UUID) {
		updateObservers[token] = nil
	}

	func fetchOrCreateCategory(withTitle title: String) throws -> NSManagedObject {
		let normalizedTitle = normalizedCategoryTitle(title)
		guard !normalizedTitle.isEmpty else {
			throw TrackerCategoryStoreError.emptyTitle
		}

		if let category = fetchCategoryObject(withTitle: normalizedTitle) {
			return category
		}

		let context = coreDataStack.viewContext
		let request = NSFetchRequest<NSManagedObject>(entityName: Constants.entityName)
		request.fetchLimit = 1
		request.predicate = NSPredicate(format: "%K ==[cd] %@", Constants.titleKey, normalizedTitle)

		if let existing = try context.fetch(request).first {
			return existing
		}

		let category = NSEntityDescription.insertNewObject(forEntityName: Constants.entityName, into: context)
		category.setValue(normalizedTitle, forKey: Constants.titleKey)
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

	private func normalizedCategoryTitle(_ title: String) -> String {
		title.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private func fetchCategoryObject(withTitle title: String) -> NSManagedObject? {
		fetchAllCategoryObjects().first(where: { object in
			let categoryTitle = (object.value(forKey: Constants.titleKey) as? String) ?? ""
			return categoryTitle.compare(title, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
		})
	}

	private func mapCategory(from categoryObject: NSManagedObject) -> TrackerCategoryItem {
		let title = (categoryObject.value(forKey: Constants.titleKey) as? String) ?? ""
		return TrackerCategoryItem(objectID: categoryObject.objectID, title: title)
	}

	private func saveContextIfNeeded() throws {
		let context = coreDataStack.viewContext
		guard context.hasChanges else { return }
		try context.save()
	}

	private func notifyDidUpdate() {
		onDidUpdate?()
		updateObservers.values.forEach { $0() }
	}
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
		notifyDidUpdate()
	}
}
