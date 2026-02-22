//
//  OnboardingPage.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//

import UIKit

struct OnboardingPage {
	let title: String
	let backgroundImageName: String
	let fallbackTopColor: UIColor
	let fallbackBottomColor: UIColor
}

enum OnboardingPalette {
	static let blueTop = UIColor(red: 0.28, green: 0.46, blue: 0.87, alpha: 1.0)
	static let blueBottom = UIColor(red: 0.90, green: 0.93, blue: 0.98, alpha: 1.0)
	static let redTop = UIColor(red: 0.94, green: 0.43, blue: 0.46, alpha: 1.0)
	static let redBottom = UIColor(red: 0.96, green: 0.88, blue: 0.89, alpha: 1.0)
}
