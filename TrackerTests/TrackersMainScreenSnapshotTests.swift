import XCTest
import CoreData
import UIKit
import SnapshotTesting
@testable import Tracker

@MainActor
final class TrackersMainScreenSnapshotTests: XCTestCase {
	override func setUp() {
		super.setUp()
		UIView.setAnimationsEnabled(false)
	}

	override func tearDown() {
		UIView.setAnimationsEnabled(true)
		super.tearDown()
	}

	func testMainScreen_EmptyState_FixedDate_iPhone16Pro() {
		let viewController = makeSUT()

		// TrackersViewController receives state updates on RunLoop.main.
		RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

		assertSnapshot(
			of: viewController,
			as: .image,
			named: "empty_fixed_date_iphone16pro"
		)
	}

	private func makeSUT() -> TrackersViewController {
		let coreDataStack = makeInMemoryCoreDataStack()
		let trackerCategoryStore = TrackerCategoryStore(coreDataStack: coreDataStack)
		let trackerStore = TrackerStore(
			coreDataStack: coreDataStack,
			categoryStore: trackerCategoryStore
		)
		let trackerRecordStore = TrackerRecordStore(coreDataStack: coreDataStack)

		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = Locale(identifier: "en_US_POSIX")
		calendar.timeZone = .current

		let viewModel = TrackersViewModel(
			trackerStore: trackerStore,
			trackerRecordStore: trackerRecordStore,
			trackerCategoryStore: trackerCategoryStore,
			initialDate: fixedDate(using: calendar),
			calendar: calendar
		)

		let viewController = TrackersViewController(viewModel: viewModel)
		viewController.overrideUserInterfaceStyle = .light
		return viewController
	}

	private func makeInMemoryCoreDataStack() -> CoreDataStack {
		let coreDataStack = CoreDataStack(modelName: "Tracker")
		let description = NSPersistentStoreDescription()
		description.type = NSInMemoryStoreType
		description.shouldAddStoreAsynchronously = false
		coreDataStack.persistentContainer.persistentStoreDescriptions = [description]
		coreDataStack.load()
		return coreDataStack
	}

	private func fixedDate(using calendar: Calendar) -> Date {
		let components = DateComponents(year: 2026, month: 1, day: 15)
		guard let date = calendar.date(from: components) else {
			XCTFail("Failed to build fixed date")
			return Date(timeIntervalSince1970: 0)
		}
		return date
	}
}
