//
//  OnboardingPageContentViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 19.02.26.
//
//

import UIKit

final class OnboardingPageContentViewController: UIViewController {
	private let page: OnboardingPage

	private let gradientView = OnboardingGradientView()

	private let backgroundImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 32, weight: .bold)
		label.textColor = .ypFixedBlack
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	init(page: OnboardingPage) {
		self.page = page
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		nil
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupConstraints()
		setupActions()
		configureContent()
	}

	private func setupViews() {
		view.backgroundColor = .clear

		gradientView.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(gradientView)
		view.addSubview(backgroundImageView)
		view.addSubview(titleLabel)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			gradientView.topAnchor.constraint(equalTo: view.topAnchor),
			gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
			backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -220)
		])
	}

	private func setupActions() {}

	private func configureContent() {
		gradientView.configure(
			topColor: page.fallbackTopColor,
			bottomColor: page.fallbackBottomColor
		)
		backgroundImageView.image = UIImage(named: page.backgroundImageName)
		titleLabel.text = page.title
	}
}

private final class OnboardingGradientView: UIView {
	override class var layerClass: AnyClass {
		CAGradientLayer.self
	}

	func configure(topColor: UIColor, bottomColor: UIColor) {
		guard let gradientLayer = layer as? CAGradientLayer else {
			return
		}
		gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
		gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
		gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
	}
}
