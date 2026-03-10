//
//  UIColor+FixedPalette.swift
//  Tracker
//
//  Created by Codex on 10.03.26.
//

import UIKit

extension UIColor {
	/// Fixed dark color used in design where black must not invert in dark mode.
	static var ypFixedBlack: UIColor {
		UIColor(red: 26 / 255, green: 27 / 255, blue: 34 / 255, alpha: 1)
	}

	/// Fixed white color used in design where white must not invert in dark mode.
	static var ypFixedWhite: UIColor {
		.white
	}
}
