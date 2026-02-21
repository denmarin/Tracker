//
//  StatisticsViewController.swift
//  Tracker
//
//

import UIKit

final class StatisticsViewController: UIViewController {
	private let viewModel: StatisticsViewModel

	init(viewModel: StatisticsViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .ypWhite
		bindViewModel()
		viewModel.viewDidLoad()
	}

	private func bindViewModel() {
		viewModel.onStateChanged = { [weak self] state in
			self?.title = state.title
		}
	}
}
