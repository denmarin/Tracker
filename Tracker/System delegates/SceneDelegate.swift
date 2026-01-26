//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 12.01.26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else { return }
		let window = UIWindow(windowScene: windowScene)
		
		let trackersVC = TrackersViewController()
		let trackersNav = UINavigationController(rootViewController: trackersVC)
		trackersNav.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(systemName: "record.circle.fill"), selectedImage: UIImage(systemName: "record.circle.fill"))
		let statisticsVC = StatisticsViewController()
		let statisticsNav = UINavigationController(rootViewController: statisticsVC)
		statisticsNav.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), selectedImage: UIImage(systemName: "hare.fill"))
		
		let tabBar = UITabBarController()
		tabBar.viewControllers = [trackersNav, statisticsNav]
		
		window.rootViewController = tabBar
		window.makeKeyAndVisible()
		self.window = window
	}
}

