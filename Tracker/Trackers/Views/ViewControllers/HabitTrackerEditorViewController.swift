//
//  HabitTrackerEditorViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//


import UIKit

final class HabitTrackerEditorViewController: TrackerEditorViewController {
	override init(viewModel: TrackerEditorViewModel) {
		precondition(viewModel.mode == .habit, "Habit screen requires .habit mode")
		super.init(viewModel: viewModel)
	}
}
