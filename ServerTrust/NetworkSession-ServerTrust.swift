//
//  NetworkSession-ServerTrust.swift
//  Avenue
//
//  Copyright © 2017 Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

//	MARK: Authentication callbacks

extension NetworkSession {
	func handleURLSession(_ session: URLSession,
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
				if let dataTask = task {
					let authError = NetworkError.urlError( URLError(.userCancelledAuthentication) )
					dataTask.errorCallback(authError)
				}
				completionHandler(.rejectProtectionSpace, nil)
				return
			}

			let credential = URLCredential(trust: trust)
			completionHandler(.useCredential, credential)
			return
		}

		completionHandler(.performDefaultHandling, nil)
	}
}

extension NetworkSession: URLSessionDelegate {

	public final func urlSession(_ session: URLSession,
								 didReceive challenge: URLAuthenticationChallenge,
								 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
	{
		handleURLSession(session, task: nil, didReceive: challenge, completionHandler: completionHandler)
	}

}

extension NetworkSession: URLSessionTaskDelegate {
	public final func urlSession(_ session: URLSession,
								 task: URLSessionTask,
								 didReceive challenge: URLAuthenticationChallenge,
								 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
	{
		handleURLSession(session, task: task as? URLSessionDataTask, didReceive: challenge, completionHandler: completionHandler)
	}
}

