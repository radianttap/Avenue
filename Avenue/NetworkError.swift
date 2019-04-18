//
//  NetworkError.swift
//  Avenue
//
//  Copyright © 2017 Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

///	Various error this library is specifically handling.
///	If you extend the capabilities of the this micro-library, you may add as many cases as you need here
public enum NetworkError: Error {
	//	Returned URLResponse is not HTTPURLResponse
	case invalidResponse

	//	Returned HTTPURLResponse has no body (see `NetworkHTTPMethod`)
	case noData

	//	NetworkOperation is cancelled before it finished
	case cancelled

	//	URLError returned by URLSession framework
	case urlError(URLError)

	//	Some non-URLError returned by URLSession framework
	case other(Swift.Error)
}

extension NetworkError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .cancelled:
			return NSLocalizedString("Request cancelled", comment: "")

		case .invalidResponse, .noData:
			return NSLocalizedString("Request failed", comment: "")

		case .urlError(let urlError):
			return (urlError as NSError).localizedDescription

		case .other(let error):
			return (error as NSError).localizedDescription
		}
	}

	public var failureReason: String? {
		switch self {
		case .cancelled:
			return nil

		case .invalidResponse:
			return NSLocalizedString("Unexpected response received (not HTTP)", comment: "")

		case .noData:
			return NSLocalizedString("Empty response (no data)", comment: "")

		case .urlError(let urlError):
			return (urlError as NSError).localizedFailureReason

		case .other(let error):
			return (error as NSError).localizedFailureReason
		}
	}
}
