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
class NetworkSession: NSObject {
	var urlSessionConfiguration: URLSessionConfiguration = .default
	var urlSession: URLSession!

	override init() {
		super.init()

		urlSession = URLSession(configuration: urlSessionConfiguration,
								delegate: self,
								delegateQueue: nil)
	}
}

extension NetworkSession: URLSessionDelegate {
	func urlSession(_ session: URLSession,
					task: URLSessionTask,
					didReceive challenge: URLAuthenticationChallenge,
					completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
	{
		urlSession(session, didReceive: challenge, completionHandler: completionHandler)
	}

	func urlSession(_ session: URLSession,
					didReceive challenge: URLAuthenticationChallenge,
					completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
	{

		if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
			guard let trust = challenge.protectionSpace.serverTrust else {
				completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
				return
			}
			let host = challenge.protectionSpace.host

			guard session.serverTrustPolicy.evaluate(trust, forHost: host) else {
				completionHandler(URLSession.AuthChallengeDisposition.rejectProtectionSpace, nil)
				return
			}

			let credential = URLCredential(trust: trust)
			completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
			return
		}

		completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
	}
}

