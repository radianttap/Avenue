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
	///   - urlRequest: `URLRequest` value to execute.
	///   - urlSession: `URLSession` instance to use for execution of task created inside this Operation.
	///   - maxRetries: Number of automatic retries (default is set during `NetworkSession.init`).
	///   - allowEmptyData: Should empty response `Data` be treated as failure (this is default) even if no other errors are returned by URLSession. Default is `false`.
	///   - callback: A closure to pass the result back
	public init(urlRequest: URLRequest,
		 urlSession: URLSession,
		 maxRetries: Int = URLSession.maximumNumberOfRetries,
		 allowEmptyData: Bool = false,
		 callback: @escaping (NetworkPayload) -> Void)
	{
		if maxRetries <= 0 {
			fatalError("maxRetries must be 1 or larger.")
		}

		self.payload = NetworkPayload(urlRequest: urlRequest)
		self.maxRetries = maxRetries
		self.allowEmptyData = allowEmptyData
		self.callback = callback
		self.urlSessionConfiguration = urlSession.configuration
		self.urlSession = urlSession

		super.init()
	}

	//MARK:- Properties

	private(set) var payload: NetworkPayload

	private(set) var callback: Callback

	///	Maximum number of retries
	private(set) var maxRetries: Int
	private var currentRetries: Int = 0

	///	If `false`, HTTPURLResponse must have some content in its body (if not, it will be treated as error)
	private(set) var allowEmptyData: Bool = false

	///	Configuration to use for the URLSession that will handle `urlRequest`
	private(set) var urlSessionConfiguration : URLSessionConfiguration

	///	URLSession that will be used for this particular request.
	///	If you don't supply it in the `init`, it will be created locally for this one request
	private var urlSession: URLSession

	///	Actual network task, executed by `urlSession`
	private(set) var task: URLSessionDataTask?

	///	This collects incoming data chunks
	private var incomingData = Data()





	//	MARK: AsyncOperation

	/// Set network start timestamp, creates URLSessionDataTask and starts it (resume)
	public final override func workItem() {
		//	First create the task
		task = urlSession.dataTask(with: payload.urlRequest)

		//	then setup handlers for URLSessionDelegate calls
		setupCallbacks()

		//	save the timestamp
		payload.start()

		//	and execute
		performTask()
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
	func performTask() {
		if currentRetries >= maxRetries {
			//	Too many unsuccessful attemps
			payload.error = .inaccessible
			finish()

			return
		}

		task?.resume()
	}

	///	Makes URLSession [cooperate nicely](https://aplus.rs/2017/urlsession-in-operation/) with Operation(Queue)
	func setupCallbacks() {
		guard let task = task else { return }

		task.errorCallback = {
			[weak self] networkError in
			guard let self = self else { return }

			switch networkError {
			case .inaccessible:
				//	too many failed network calls
				break

			default:
				if networkError.shouldRetry {
					//	update retries count and
					self.currentRetries += 1
					//	try again
					self.performTask()
					return
				}
			}

			self.payload.error = networkError
			self.finish()
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
			guard let httpURLResponse = self.payload.response else { return }

			if httpURLResponse.statusCode >= 400 {
				task.errorCallback( NetworkError.endpointError(httpURLResponse, self.incomingData) )
				return
			}

			if !self.allowEmptyData, self.incomingData.isEmpty {
				task.errorCallback( NetworkError.noResponseData(httpURLResponse) )
				return
			}

			self.payload.data = self.incomingData
			self.finish()
		}
	}
}
