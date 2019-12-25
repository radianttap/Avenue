//
//  NetworkOperation.swift
//  Avenue
//
//  Copyright © 2017 Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

/// Subclass of [AsyncOperation](https://github.com/radianttap/Swift-Essentials/blob/master/Operation/AsyncOperation.swift)
///	that handles most aspects of direct data download over network.
///
///	You need 3 things for the init: `URLSession` instance, `URLRequest` as input and `Callback` as output.
public class NetworkOperation: AsyncOperation {
	public typealias Callback = (NetworkPayload) -> Void

	required init() {
		fatalError("Use the `init(urlRequest:urlSession:callback:)`")
	}


	/// Designated initializer, it will execute the URLRequest using supplied URLSession instance.
	///
	///	It‘s assumed that URLSessionDelegate is defined elsewhere (see `NetworkSession`) and stuff will be called-in here (see `setupCallbacks()`).
	///
	/// - Parameters:
	///   - urlRequest: `URLRequest` value to execute
	///   - urlSession: URLSession instance to use for task created in this Operation
	///   - callback: A closure to pass the result back
	public init(urlRequest: URLRequest,
		 urlSession: URLSession,
		 callback: @escaping (NetworkPayload) -> Void)
	{
		self.payload = NetworkPayload(urlRequest: urlRequest)
		self.callback = callback
		self.urlSessionConfiguration = urlSession.configuration
		self.urlSession = urlSession
		super.init()

		processHTTPMethod()
	}

	//MARK:- Properties

	private(set) var payload: NetworkPayload
	private(set) var callback: Callback

	///	Configuration to use for the URLSession that will handle `urlRequest`
	private(set) var urlSessionConfiguration : URLSessionConfiguration

	///	URLSession that will be used for this particular request.
	///	If you don't supply it in the `init`, it will be created locally for this one request
	private var urlSession: URLSession

	///	Actual network task, executed by `urlSession`
	private(set) var task: URLSessionDataTask?

	///	This collects incoming data chunks
	private var incomingData = Data()

	///	By default, Operation will not treat empty data in the response as error.
	///	This is normal with HEAD, PUT or DELETE methods, so this value will be changed
	///	based on the URLRequest.httpMethod value.
	///	`NetworkHTTPMethod` however declares that GET and POST requests must return some data.
	///
	///	If you want to override the default behavior, make sure to set this value
	///	*after* you create the `NetworkOperation` instance but *before* you add to the `OperationQueue`.
	open var allowEmptyData: Bool = true





	//	MARK: AsyncOperation

	/// Set network start timestamp, creates URLSessionDataTask and starts it (resume)
	public final override func workItem() {
		//	First create the task
		task = urlSession.dataTask(with: payload.urlRequest)

		//	then setup handlers for URLSessionDelegate calls
		setupCallbacks()

		//	save the timestamp
		payload.start()
		//	and start it
		task?.resume()
	}

	private func finish() {
		payload.end()

		markFinished()

		callback(payload)
	}

	public final override func cancel() {
		super.cancel()

		task?.cancel()

		//	since the Operation is cancelled, clear out any results that we may have received so far
		payload.data = nil
		payload.error = nil
		payload.response = nil

		//	not calling `finish()`, to avoid setting `payload.tsEnd` since it never actually finished
		//	but must mark Operation as complete so OperationQueue can continue with next one
		markFinished()
		//	report back with the payload as it is
		callback(payload)
	}
}

//	MARK:- Internal

private extension NetworkOperation {
	///	Sets `allowEmptyData` per `NetworkHTTPMethod.allowsEmptyResponseData`
	func processHTTPMethod() {
		guard
			let method = payload.originalRequest.httpMethod,
			let m = NetworkHTTPMethod(rawValue: method)
		else { return }

		allowEmptyData = m.allowsEmptyResponseData
	}

	///	Makes URLSession [cooperate nicely](http://aplus.rs/2017/urlsession-in-operation/) with Operation(Queue)
	func setupCallbacks() {
		guard let task = task else { return }

		task.errorCallback = {
			[weak self] error in
			self?.payload.error = error
			self?.finish()
		}

		task.responseCallback = {
			[weak self] httpResponse in
			self?.payload.response = httpResponse
		}

		task.dataCallback = {
			[weak self] data in
			self?.incomingData.append(data)
		}

		task.finishCallback = {
			[weak self] in
			guard let self = self else { return }

			if self.incomingData.isEmpty && !self.allowEmptyData {
				self.payload.error = .noData
				self.finish()
				return
			}

			self.payload.data = self.incomingData
			self.finish()
		}
	}
}
