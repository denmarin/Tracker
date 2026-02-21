//
//  HabitCreationViewController.swift
//  Tracker
//


import UIKit

final class HabitCreationViewController: CreationViewController {
	override init(viewModel: CreationViewModel) {
		precondition(viewModel.mode == .habit, "Habit screen requires .habit mode")
		super.init(viewModel: viewModel)
	}
}
