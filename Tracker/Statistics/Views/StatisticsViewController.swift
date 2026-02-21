//
//  StatisticsViewController.swift
//  Tracker
//
//

import UIKit
import Combine

final class StatisticsViewController: UIViewController {
	private let viewModel: StatisticsViewModel
	private var cancellables = Set<AnyCancellable>()

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
		viewModel.statePublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] state in
				self?.title = state.title
			}
			.store(in: &cancellables)
	}
}
