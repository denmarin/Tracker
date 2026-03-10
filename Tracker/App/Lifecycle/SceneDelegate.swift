//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 12.01.26.
//



import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	// MARK: - Properties

	var window: UIWindow?
	private var appCoordinator: AppCoordinator?

	// MARK: - UIWindowSceneDelegate

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let windowScene = scene as? UIWindowScene else { return }
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			fatalError("AppDelegate not found")
		}

		let window = UIWindow(windowScene: windowScene)
		let dependencies = AppDependencyContainer(coreDataStack: appDelegate.coreDataStack)
		let coordinator = AppCoordinator(
			window: window,
			dependencies: dependencies
		)

		coordinator.start()
		window.makeKeyAndVisible()

		self.appCoordinator = coordinator
		self.window = window
	}
}
