//
//  IrregularEventCreationViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//


import UIKit

final class IrregularEventCreationViewController: CreationViewController {
	override init(viewModel: CreationViewModel) {
		precondition(viewModel.mode == .irregularEvent, "Irregular event screen requires .irregularEvent mode")
		super.init(viewModel: viewModel)
	}
}
