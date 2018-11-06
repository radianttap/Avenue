//
//  ViewController.swift
//  Demo
//
//  Created by Aleksandar Vacić on 19.8.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
	//	UI

	@IBOutlet private weak var textView: UITextView!

	//	Dependencies

	private lazy var service: IvkoService = {
		return IvkoService.shared
	}()

	private lazy var assetManager: AssetManager = {
		return AssetManager.shared
	}()

	//	View Lifecycle

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		let path = IvkoService.Path.promotions
		service.call(path: path) {
			[weak self] json, serviceError in

			DispatchQueue.main.async {
				guard let `self` = self else { return }

				if let serviceError = serviceError {
					self.textView.text = serviceError.localizedDescription
					return
				}

				self.textView.text = "Completed network call to IvkoService.Path.\( path )\n(See Xcode console for details)"
			}
		}
	}
}

