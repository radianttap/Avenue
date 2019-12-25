//
//  NetworkSession.swift
//  Avenue
//
//  Copyright © 2017 Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//
//	Relevant documentation:
//	(1) ATS (Advanced Transport Security):
//	https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33
//	(2) TN2232: HTTPS Server Trust Evaluation
//	https://developer.apple.com/library/content/technotes/tn2232/
//
//	Helpful articles:
//	https://www.nowsecure.com/blog/2017/08/31/security-analysts-guide-nsapptransportsecurity-nsallowsarbitraryloads-app-transport-security-ats-exceptions/
//	https://github.com/Alamofire/Alamofire#app-transport-security
//	https://github.com/Alamofire/Alamofire/issues/876
//	https://infinum.co/the-capsized-eight/how-to-make-your-ios-apps-more-secure-with-ssl-pinning
//
//	Tools:
//	https://badssl.com
//	nscurl --help (in your macOS Terminal)



import Foundation

///	Base class that handles URLSession-level stuff. Subclass it to build your API / web-endpoint wrapper.
///
///	This is very shallow class; its purpose is to handle Authentication challenges, but due to
///	general URLSession/DataTask architecture, it also must handle the task-level URLSessionDelegate methods.
///
///	This is accomplished by forcefully expanding URLSessionDataTask, see NetworkTask.swift
///
///	Auth challenges like ServerTrust will be automatically handled, using URLSession.serverTrustPolicy value (defined elsewhere).
///	`userCancelledAuthentication` error will be returned if evaluation fails.
open class NetworkSession: NSObject {
	public private(set) var urlSessionConfiguration: URLSessionConfiguration
	public private(set) var urlSession: URLSession!

	private override init() {
		fatalError("Must use `init(urlSessionConfiguration:)")
	}

	public init(urlSessionConfiguration: URLSessionConfiguration = .default) {
		self.urlSessionConfiguration = urlSessionConfiguration
		super.init()

		urlSession = URLSession(configuration: urlSessionConfiguration,
								delegate: self,
								delegateQueue: nil)
	}

	deinit {
		//	this cancels immediatelly
		//	urlSession.invalidateAndCancel()

		//	this will allow background tasks to finish-up first
		urlSession.finishTasksAndInvalidate()
	}
}

//	MARK: Data callbacks

extension NetworkSession: URLSessionDataDelegate {
	//	this checks the response headers
	public final func urlSession(_ session: URLSession,
								 dataTask: URLSessionDataTask,
								 didReceive response: URLResponse,
								 completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
	{
		guard let httpURLResponse = response as? HTTPURLResponse else {
			completionHandler(.cancel)
			dataTask.errorCallback(.invalidResponseType(response))
			return
		}

		//	for now, just save the response headers
		dataTask.responseCallback(httpURLResponse)
		//	checking statusCode will be done in task.finishCallback,
		//	in order to first receive possible error message in the body

		//	always allow data to arrive in order to
		//	extract possible API error messages
		completionHandler(.allow)
	}

	//	this will be called multiple times while the data is coming in
	public final func urlSession(_ session: URLSession,
								 dataTask: URLSessionDataTask,
								 didReceive data: Data)
	{
		dataTask.dataCallback(data)
	}

	//	this is called once, either on URLError or when entire response arrives
	public final func urlSession(_ session: URLSession,
								 task: URLSessionTask,
								 didCompleteWithError error: Swift.Error?)
	{
		guard let dataTask = task as? URLSessionDataTask else { return }

		if let urlError = error as? URLError {
			dataTask.errorCallback( .urlError(urlError) )
			return

		} else if let otherError = error {
			dataTask.errorCallback( .generalError(otherError) )
			return
		}

		dataTask.finishCallback()
	}
}

