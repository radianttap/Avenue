//
//  IvkoServiceError.swift
//  CoordinatorExample
//
//  Created by Aleksandar Vacić on 20.8.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import Foundation
import Avenue


enum IvkoServiceError: Error {
	case network(NetworkError?)
	case unexpectedResponse(HTTPURLResponse, String?)
}
