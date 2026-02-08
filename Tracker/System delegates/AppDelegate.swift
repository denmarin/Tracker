//
//  AppDelegate.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 12.01.26.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

	let coreDataStack = CoreDataStack()


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		coreDataStack.load()
		return true
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		coreDataStack.saveContext()
	}

	func applicationWillTerminate(_ application: UIApplication) {
		coreDataStack.saveContext()
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
	}


}
