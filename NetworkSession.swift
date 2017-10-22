//
//  NetworkSession.swift
//  Radiant Tap Essentials
//
//  Copyright © 2017 Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

///	Base class that handles URLSession-level stuff. Subclass it to build your API / web-endpoint wrapper.
///
///	This is very shallow class; its purpose is to handle Authentication challenges, but due to
///	general URLSession/DataTask architecture, it also must handle the task-level URLSessionDelegate methods.
///
///	This is accomplished by forcefully expanding URLSessionDataTask, see NetworkTask.swift
class NetworkSession: NSObject {
	var urlSessionConfiguration: URLSessionConfiguration
	var urlSession: URLSession!

	private override init() {
		fatalError("Must use `init(urlSessionConfiguration:)")
	}

	init(urlSessionConfiguration: URLSessionConfiguration = .default) {
		self.urlSessionConfiguration = urlSessionConfiguration
		super.init()

		urlSession = URLSession(configuration: urlSessionConfiguration,
								delegate: self,
								delegateQueue: nil)
	}

	deinit {
		//	this cancels immediatelly
//		urlSession.invalidateAndCancel()
		//	this will allow background tasks to finish-up first
		urlSession.finishTasksAndInvalidate()
	}
}

extension NetworkSession: URLSessionDataDelegate {
	//	MARK: Authentication callbacks

	func urlSession(_ session: URLSession,
					didReceive challenge: URLAuthenticationChallenge,
					completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
	{
		handleURLSession(session, task: nil, didReceive: challenge, completionHandler: completionHandler)
	}

	func urlSession(_ session: URLSession,
					task: URLSessionTask,
					didReceive challenge: URLAuthenticationChallenge,
					completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
	{
		handleURLSession(session, task: task as? URLSessionDataTask, didReceive: challenge, completionHandler: completionHandler)
	}

	fileprivate func handleURLSession(_ session: URLSession,
									 task: URLSessionDataTask?,
									 didReceive challenge: URLAuthenticationChallenge,
									 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
	{
		if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
			guard let trust = challenge.protectionSpace.serverTrust else {
				completionHandler(.performDefaultHandling, nil)
				return
			}
			let host = challenge.protectionSpace.host

			guard session.serverTrustPolicy.evaluate(trust, forHost: host) else {
				completionHandler(.rejectProtectionSpace, nil)

				if let dataTask = task {
					let authError = NetworkError.urlError( NSError(domain: NSURLErrorDomain,
																   code: URLError.userCancelledAuthentication.rawValue,
																   userInfo: nil) as? URLError )
					dataTask.errorCallback(authError)
				}
				return
			}

			let credential = URLCredential(trust: trust)
			completionHandler(.useCredential, credential)
			return
		}

		completionHandler(.performDefaultHandling, nil)
	}

	//	MARK: Data callbacks

	//	this checks the response headers
	final func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
		guard let httpResponse = response as? HTTPURLResponse else {
			completionHandler(.cancel)
			dataTask.errorCallback(.invalidResponse)
			return
		}

		dataTask.responseCallback(httpResponse)

		//	always allow data to arrive in order to
		//	extract possible API error messages
		completionHandler(.allow)
	}

	//	this will be called multiple times while the data is coming in
	final func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		dataTask.dataCallback(data)
	}

	final func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
		guard let dataTask = task as? URLSessionDataTask else { return }

		if let e = error {
			dataTask.errorCallback( .urlError(e as? URLError) )
			return
		}
		dataTask.finishCallback()
	}
}

