//
//  NetworkError.swift
//  Radiant Tap Essentials
//
//  Copyright © 2017 Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

public enum NetworkError: Error {
	case invalidResponse

	case noData

	case cancelled

	case urlError(URLError?)
}

