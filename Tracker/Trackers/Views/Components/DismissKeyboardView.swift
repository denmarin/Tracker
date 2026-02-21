//
//  DismissKeyboardView.swift
//  Tracker
//


import UIKit

/// A container view that dismisses the keyboard when tapping on empty space, but doesn't
/// interfere with interactions on controls like UITextField, UIButton, UISwitch, etc.
final class DismissKeyboardView: UIView {
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gr.cancelsTouchesInView = false // don't block touches for subviews
        gr.delaysTouchesBegan = false
        gr.delaysTouchesEnded = false
        gr.delegate = self
        return gr
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(tapRecognizer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addGestureRecognizer(tapRecognizer)
    }

    @objc private func handleTap() {
        endEditing(true)
    }
}
extension DismissKeyboardView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Don't trigger on taps that land on interactive controls or text views (or their subviews)
        var view: UIView? = touch.view
        while let v = view {
            if v is UIControl || v is UITextView { return false }
            view = v.superview
        }
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow other gestures (e.g., scroll view pans, control tracking) to work alongside our tap.
        return true
    }
}

