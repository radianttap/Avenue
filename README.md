[![](https://img.shields.io/github/tag/radianttap/Avenue.svg?label=current)](https://github.com/radianttap/Avenue/releases)
![platforms: iOS|tvOS|watchOS](https://img.shields.io/badge/platform-iOS|tvOS|watchOS-blue.svg)
[![](https://img.shields.io/github/license/radianttap/Avenue.svg)](https://github.com/radianttap/Avenue/blob/master/LICENSE)
<br>
![](https://img.shields.io/badge/swift-5-223344.svg?logo=swift&labelColor=FA7343&logoColor=white)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-AD4709.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-fb0006.svg)](https://cocoapods.org)

# Avenue

Micro-library designed to allow seamless cooperation between URLSession(Data)Task and Operation(Queue) APIs.

## Why?

URLSession framework is, on its own, [incompatible](https://aplus.rs/2017/thoughts-on-urlsession/) with Operation API. A bit of [trickery is required](https://aplus.rs/2017/urlsession-in-operation/) to make them cooperate.
(note: do read those blog posts)

I have [extended URLSessionTask](https://github.com/radianttap/Avenue/blob/master/Avenue/URLSessionTask-Extensions.swift) with additional properties of specific closure types which allows you to overcome this incompatibility. 

`OperationQueue` and `Operation` are great API to use when...

* your network requests are inter-dependent on each other
* need to implement OAuth2 or any other kind of asynchronous 3rd-party authentication mechanism
* tight control over the number of concurrent requests towards a particular host is paramount
* etc.

> If this is too complex for your needs, take a look at [Alley](https://github.com/radianttap/Alley) — it’s much simpler but surprisingly capable.

## Installation

### Manually

- If you are not using [Swift Essentials](https://github.com/radianttap/Swift-Essentials) already, make sure to include `Essentials` folder from here into your project
- Also add `Avenue` and `Alley`, just copy them into your project.
- To handle self-signed SSL, pinned certificates and other similar security stuff - add `ServerTrust` as well.

· · ·

If you prefer to use dependency managers, see below. 
Releases are tagged with [Semantic Versioning](https://semver.org) in mind.

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Avenue into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'Avenue', 	:git => 'https://github.com/radianttap/Avenue.git'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Avenue into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "radianttap/Avenue"
```

## Usage

(1) Subclass `NetworkSession` to create your API wrapper, configure `URLSession` for the given service endpoints and make an `OperationQueue` instance. 

```swift
final class WebService: NetworkSession {
	private init() {
		queue = {
			let oq = OperationQueue()
			oq.qualityOfService = .userInitiated
			return oq
		}()

		let urlSessionConfiguration: URLSessionConfiguration = {
			let c = URLSessionConfiguration.default
			c.allowsCellularAccess = true
			c.httpCookieAcceptPolicy = .never
			c.httpShouldSetCookies = false
			c.requestCachePolicy = .reloadIgnoringLocalCacheData
			return c
		}()

		super.init(urlSessionConfiguration: urlSessionConfiguration)
	}

	//	Local stuff

	private var queue: OperationQueue
}
```

(2) Model API endpoints in any way you want. See _IvkoService_ example in the Demo app for one possible way, using enum with associated values.

The end result of that model would be `URLRequest` instance.

(3) Create an instance of `NetworkOperation` and add it to the `queue`

```swift
let op = NetworkOperation(urlRequest: urlRequest, urlSession: urlSession) {
	payload in
	//   ...process NetworkPayload...
}
queue.addOperation(op)
```

It will be automatically executed. You can also supply the desired number of automatic retries, among other arguments.

> See `AssetManager` and `IvkoService` in the Demo project, as examples. Write as many of these as you need.

### Tips

* Avenue handles just the URLSession boilerplate: URLErrors, HTTP Auth challenges, Server Trust Policy etc. 

* The only assumption Avenue makes is that web service you connect to is HTTP(S) based. 

* `NetworkPayload` is particularly useful struct since it aggregates `URLRequest` + response headers, data and error _and_ gives you simple speed metering capability by recording start and end of each network call.

* `ServerTrustPolicy` is directly picked up from [Alamofire v4](https://github.com/Alamofire/Alamofire/tree/4.8.1); it’s great as it is and there’s no need for me to reinvent the wheel.

* Set `ServerTrustPolicy.defaultPolicy` in your project configuration file (or wherever is appropriate) to the value you need for each app target you have. For example, if you connect to some self-signed demo API host:\
`ServerTrustPolicy.defaultPolicy = .disableEvaluation`

Note: `AsyncOperation` is my own [simple subclass](https://github.com/radianttap/Swift-Essentials/blob/master/Operation/AsyncOperation.swift) which makes sure that `Operation` is marked `finished` only when the network async callback returns. `Atomic.swift` is required by `AsyncOperation`.

## Compatibility

Platform and Swift compatibility is listed at the top of this document.

## License

[MIT License,](https://github.com/radianttap/Avenue/blob/v2/LICENSE) like all my open source code.

## Credits

* **Alamofire** community for their invaluable work over the years. I don’t use the library itself, but there are re-usable gems in it (like ServerTrustPolicy handling).

* **Marcus Zarra** for this [great talk](https://academy.realm.io/posts/slug-marcus-zarra-exploring-mvcn-swift/) which got me started to write this library. There’s a [blog post](http://www.cimgf.com/2016/01/28/a-modern-network-operation/) on his blog too.

I want re-iterate what Marcus said at the end of his talk:

> Write it [network code] yourself. I guarantee code you write yourself will be faster than any generic code, that is the law. Whenever you write something that is very specific, it is going to be faster than generics.

## Learn more

* [Alley](https://github.com/radianttap/Alley) – automatic retries for `URLSessionDataTask`

* ATS ([Advanced Transport Security](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33))

* TN2232: [HTTPS Server Trust Evaluation](https://developer.apple.com/library/content/technotes/tn2232/)

* WWDC 2017, Session 709: [Advances in Networking, Part 2](http://developer.apple.com/videos/play/wwdc2017/709)

### Helpful articles

* [Security analysis](https://www.nowsecure.com/blog/2017/08/31/security-analysts-guide-nsapptransportsecurity-nsallowsarbitraryloads-app-transport-security-ats-exceptions/) of ATS

* Alamofire [notes on ATS](https://github.com/Alamofire/Alamofire#app-transport-security)
* Resolving [ATS issues](https://github.com/Alamofire/Alamofire/issues/876)

* [Use SSL pinning](https://infinum.co/the-capsized-eight/how-to-make-your-ios-apps-more-secure-with-ssl-pinning)

### Tools

* [Bad SSL](https://badssl.com) in many ways, fantastic resource to test your code.

* `nscurl --help` (in your macOS Terminal)
