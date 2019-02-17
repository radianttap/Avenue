//
//  NetworkPayload.swift
//  Avenue
//
//  Copyright © 2017 Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

/// A simple struct to use as network "result".
///	As `NetworkOperation` is processing, its varuous propertues will be populated along the way.
public struct NetworkPayload {
	///	The original value of URLRequest at the start of the operation
	public let originalRequest: URLRequest

	///	At the start, this is identical to `originalRequest`.
	///	But, you may need to alter the original as the network processing is ongoing.
	///	i.e. you can pass the original request through OAuth library and thus update it.
	public var urlRequest: URLRequest

	public init(urlRequest: URLRequest) {
		self.originalRequest = urlRequest
		self.urlRequest = urlRequest
	}

	
	//	MARK: Result properties

	///	Any error that URLSession may populate (timeouts, no connection etc)
	public var error: NetworkError?

	///	Received HTTP response. Use it to process status code and headers
	public var response: HTTPURLResponse?

	///	Received stream of bytes
	public var data: Data?


	//	MARK: Timestamps

	///	Moment when the payload was prepared. May not be the same as `tsStart`
	public let tsCreated = Date()

	///	Moment when network task is started (you called `task.resume()` for the first time).
	///	Call `.start()` to set it.
	public private(set) var tsStart: Date?

	///	Moment when network task has ended. Used together with `tsStart` makes for simple speed metering.
	///	Call `.end()` to set it.
	public private(set) var tsEnd: Date?
}

extension NetworkPayload {
	///	Call this along with `task.resume()`
	mutating func start() {
		self.tsStart = Date()
	}

	///	Called when URLSessionDataTask ends.
	mutating func end() {
		self.tsEnd = Date()
	}
}

