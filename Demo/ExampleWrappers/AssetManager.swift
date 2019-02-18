//
//  AssetManager.swift
//  CoordinatorExample
//
//  Created by Aleksandar Vacić on 20.8.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit
import Avenue

final class AssetManager: NetworkSession {
	static let shared = AssetManager()

	private init() {
		queue = {
			let oq = OperationQueue()
			oq.qualityOfService = .userInitiated
			return oq
		}()

		let urlSessionConfiguration: URLSessionConfiguration = {
			let c = URLSessionConfiguration.default
			c.allowsCellularAccess = true
			c.httpCookieAcceptPolicy = .never
			c.httpShouldSetCookies = false
			c.requestCachePolicy = .reloadIgnoringLocalCacheData
			return c
		}()
		super.init(urlSessionConfiguration: urlSessionConfiguration)
	}

	//	Local stuff

	private var queue: OperationQueue
}

extension AssetManager {
	func cleanurl() -> URL? {
		return baseURL
	}

	func url(forProductPath path: String) -> URL? {
		return baseURL.appendingPathComponent("products", isDirectory: true).appendingPathComponent(path)
	}

	func url(forPromoPath path: String) -> URL? {
		return baseURL.appendingPathComponent("slides", isDirectory: true).appendingPathComponent(path)
	}
}

extension AssetManager {
	typealias ServiceCallback = ( JSON?, Error? ) -> Void

	func call(url: URL, callback: @escaping ServiceCallback) {
		let urlRequest = URLRequest(url: url)
		execute(urlRequest, callback: callback)
	}
}



fileprivate extension AssetManager {
	//	MARK:- Common params and types

	var baseURL : URL {
		guard let url = URL(string: "https://self-signed.badssl.com") else { fatalError("Can't create base URL!") }
		return url
	}

	static let commonHeaders: [String: String] = {
		return [
			"User-Agent": userAgent,
			"Accept-Charset": "utf-8",
			"Accept-Encoding": "gzip, deflate"
		]
	}()

	static var userAgent: String = {
	#if os(watchOS)
		let osName = "watchOS"
		let osVersion = ""
		let deviceVersion = "Apple Watch"
	#else
		let osName = UIDevice.current.systemName
		let osVersion = UIDevice.current.systemVersion
		let deviceVersion = UIDevice.current.model
	#endif

		let locale = Locale.current.identifier
		return "\( Bundle.appName ) \( Bundle.appVersion ) (\( Bundle.appBuild )); \( deviceVersion ); \( osName ) \( osVersion ); \( locale )"
	}()

	//	MARK:- Execution

	func execute(_ urlRequest: URLRequest, callback: @escaping ServiceCallback) {
		let op = NetworkOperation(urlRequest: urlRequest, urlSession: urlSession) {
			//			[unowned self]
			payload in

			if let tsStart = payload.tsStart, let tsEnd = payload.tsEnd {
				let period = tsEnd.timeIntervalSince(tsStart) * 1000
				print("\t⏱: \( period ) ms")
			}

			print(payload)
		}

		queue.addOperation(op)
	}
}

