//
//  TrackersViewControllerSnapshotTests.swift
//  TrackerTests
//
//  Created by Yury Semenyushkin on 10.03.26.
//

import CoreData
import SnapshotTesting
import XCTest
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {
	override func setUp() {
		super.setUp()
		continueAfterFailure = false
	}

	func testMainScreenSnapshot_inRussian() {
		XCTAssertEqual(String(localized: "trackers.title"), "Трекеры")

		let viewController = makeSUT()

		assertSnapshot(
			of: viewController,
			as: .wait(for: 0.1, on: .image(on: .iPhoneSe)),
			named: "main_screen_ru_light",
			record: isRecordingSnapshots
		)
	}

	private var isRecordingSnapshots: Bool {
		ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"
	}

	private func makeSUT() -> UIViewController {
		let coreDataStack = makeInMemoryCoreDataStack()
		let categoryStore = TrackerCategoryStore(coreDataStack: coreDataStack)
		let trackerStore = TrackerStore(coreDataStack: coreDataStack, categoryStore: categoryStore)
		let trackerRecordStore = TrackerRecordStore(coreDataStack: coreDataStack)

		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = Locale(identifier: "ru_RU")
		calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

		let viewModel = TrackersViewModel(
			trackerStore: trackerStore,
			trackerRecordStore: trackerRecordStore,
			trackerCategoryStore: categoryStore,
			initialDate: makeFixedDate(),
			calendar: calendar
		)

		let trackersViewController = TrackersViewController(viewModel: viewModel)
		trackersViewController.overrideUserInterfaceStyle = .light

		let navigationController = UINavigationController(rootViewController: trackersViewController)
		navigationController.overrideUserInterfaceStyle = .light
		return navigationController
	}

	private func makeInMemoryCoreDataStack() -> CoreDataStack {
		let coreDataStack = CoreDataStack()
		let description = NSPersistentStoreDescription()
		description.type = NSInMemoryStoreType
		description.shouldAddStoreAsynchronously = false
		coreDataStack.persistentContainer.persistentStoreDescriptions = [description]
		coreDataStack.load()
		return coreDataStack
	}

	private func makeFixedDate() -> Date {
		var components = DateComponents()
		components.year = 2026
		components.month = 1
		components.day = 12
		components.hour = 12
		components.minute = 0
		components.second = 0
		components.timeZone = TimeZone(secondsFromGMT: 0)
		return Calendar(identifier: .gregorian).date(from: components) ?? Date(timeIntervalSince1970: 0)
	}
}
