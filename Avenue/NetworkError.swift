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
