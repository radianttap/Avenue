//
//  Network-Extensions.swift
//  Avenue
//
//  Copyright © 2017 Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation
#if os(iOS)
import WebKit
#endif



extension ServerTrustPolicy {
	///	Default value to use throughout the app, aids consistency.
	///	URLSession and WKWebView‘s `serverTrustPolicy` should use this value.
	///
	///	ATTENTION:
	///	Override this setting in some configuration .swift file, per target.
	///	So you can have diff. setting for development, testing, production build etc.
	public static var defaultPolicy: ServerTrustPolicy = .performDefaultEvaluation(validateHost: true)
}



//	These below will simply follow what the setting above is

extension URLSession {
	public var serverTrustPolicy : ServerTrustPolicy {
		return ServerTrustPolicy.defaultPolicy
	}
}

#if os(iOS)
extension WKWebView {
	public var serverTrustPolicy : ServerTrustPolicy {
		return ServerTrustPolicy.defaultPolicy
	}
}
#endif

