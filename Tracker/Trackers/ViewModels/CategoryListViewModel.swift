//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//


import Foundation
import CoreData

final class CategoryListViewModel {
	var onRowsChanged: (([CategoryRowViewData]) -> Void)?
	var onEmptyStateChanged: ((Bool) -> Void)?
	var onRequestCategoryCreation: (() -> Void)?
	var onRequestCategoryEditing: ((TrackerCategoryItem) -> Void)?
	var onRequestCategoryDeletionConfirmation: (() -> Void)?
	var onSelectedCategoryChanged: ((String?) -> Void)?
	var onSelectionConfirmed: (() -> Void)?

	private let categoryStore: TrackerCategoryStore
	private var categories: [TrackerCategoryItem] = []
	private var selectedCategoryObjectID: NSManagedObjectID?
	private var pendingDeletionObjectID: NSManagedObjectID?
	private var updateObserverToken: UUID?

	init(categoryStore: TrackerCategoryStore, initiallySelectedCategoryTitle: String?) {
		self.categoryStore = categoryStore
		if
			let initiallySelectedCategoryTitle,
			let selectedCategory = categoryStore.category(forTitle: initiallySelectedCategoryTitle)
		{
			selectedCategoryObjectID = selectedCategory.objectID
		}
	}

	deinit {
		if let updateObserverToken {
			categoryStore.removeUpdateObserver(updateObserverToken)
		}
	}

	func viewDidLoad() {
		bindCategoryStoreUpdates()
		reloadCategories()
	}

	func didTapAddCategory() {
		onRequestCategoryCreation?()
	}

	func didSelectCategory(at index: Int) {
		guard let category = category(at: index) else { return }
		selectedCategoryObjectID = category.objectID
		emitSelection()
		emitRows()
		onSelectionConfirmed?()
	}

	func didTapEditCategory(at index: Int) {
		guard let category = category(at: index) else { return }
		onRequestCategoryEditing?(category)
	}

	func didTapDeleteCategory(at index: Int) {
		guard let category = category(at: index) else { return }
		pendingDeletionObjectID = category.objectID
		onRequestCategoryDeletionConfirmation?()
	}

	func cancelCategoryDeletion() {
		pendingDeletionObjectID = nil
	}

	@discardableResult
	func confirmCategoryDeletion() -> String? {
		guard let pendingDeletionObjectID else { return nil }
		do {
			try categoryStore.deleteCategory(with: pendingDeletionObjectID)
			if selectedCategoryObjectID == pendingDeletionObjectID {
				selectedCategoryObjectID = nil
				emitSelection()
			}
			self.pendingDeletionObjectID = nil
			reloadCategories()
			return nil
		} catch {
			self.pendingDeletionObjectID = nil
			return errorMessage(for: error)
		}
	}

	@discardableResult
	func createCategory(title: String) -> String? {
		do {
			_ = try categoryStore.createCategory(title: title)
			reloadCategories()
			return nil
		} catch {
			return errorMessage(for: error)
		}
	}

	@discardableResult
	func updateCategory(with objectID: NSManagedObjectID, title: String) -> String? {
		do {
			try categoryStore.updateCategory(with: objectID, newTitle: title)
			reloadCategories()
			if selectedCategoryObjectID == objectID {
				emitSelection()
			}
			return nil
		} catch {
			return errorMessage(for: error)
		}
	}

	private func bindCategoryStoreUpdates() {
		guard updateObserverToken == nil else { return }
		updateObserverToken = categoryStore.addUpdateObserver { [weak self] in
			self?.reloadCategories()
		}
	}

	private func reloadCategories() {
		categories = categoryStore.fetchCategories()
		if let selectedCategoryObjectID,
		   categories.contains(where: { $0.objectID == selectedCategoryObjectID }) == false
		{
			self.selectedCategoryObjectID = nil
		}

		emitRows()
		emitSelection()
	}

	private func emitRows() {
		let rows = categories.enumerated().map { index, category in
			CategoryRowViewData(
				objectID: category.objectID,
				title: category.title,
				isSelected: category.objectID == selectedCategoryObjectID,
				isFirst: index == 0,
				isLast: index == categories.count - 1
			)
		}
		onRowsChanged?(rows)
		onEmptyStateChanged?(rows.isEmpty)
	}

	private func emitSelection() {
		let selectedTitle = categories.first(where: { $0.objectID == selectedCategoryObjectID })?.title
		onSelectedCategoryChanged?(selectedTitle)
	}

	private func category(at index: Int) -> TrackerCategoryItem? {
		guard categories.indices.contains(index) else { return nil }
		return categories[index]
	}

	private func errorMessage(for error: Error) -> String {
		if let localizedError = error as? LocalizedError, let message = localizedError.errorDescription {
			return message
		}

		return String(localized: "category.error.operationFailed")
	}
}
