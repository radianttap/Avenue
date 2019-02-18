//
//  AppDelegate.swift
//  Demo
//
//  Created by Aleksandar Vacić on 19.8.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit
import Avenue

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		//	Example: disable HTTPS server-trust checks for development
		ServerTrustPolicy.defaultPolicy = .disableEvaluation

		return true
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		return true
	}

}

