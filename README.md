# Avenue
(formerly Swift-Network)

Simple, strictly focused micro-library you should use as foundation for your web service client code. Or 

## Setup

This is really simple micro-library. It could have just few files but I deliberately split into multiple files, for clarity and easier maintenance.

I expect that you may need to tweak some things here and there. Add your own custom `NetworkError` case or similar. That’s why…

### No CocoaPods. No Carthage. 

Not everything needs to be packaged like external library. It’s ok to just copy stuff into your project.

### Instructions

(1) I usually create `Vendor` folder group for all 3rd-party code, then inside it I have `Avenue` folder and copy the files from `Sources`:

```
Vendor/
  Avenue/
    Atomic.swift
    AsyncOperation.swift
    Network-Extensions.swift
    NetworkError.swift
    NetworkHTTPMethod.swift
    NetworkOperation.swift
    NetworkPayload.swift
    NetworkSession.swift
    NetworkTask.swift
    ServerTrustPolicy.swift
```

(2) Open `Network-Extensions.swift`, read the ATTENTION notice and act accordingly, if needed.

## Usage

* `NetworkSession` is main class. To write your API wrapper, you should subclass it and simply provide the desired `URLSessionConfiguration` you need. 

> See `AssetManager` and `IvkoService` in the Demo project, as examples. Write as many of these as you need.

* Wrap each network request you make into `NetworkOperation` and use an `OperationQueue` to manage them. There should be no need to subclass it further but don’t be afraid to do so.

* Extend `NetworkError` enum with more cases if you need them.

* `NetworkPayload` is particularly useful struct since it aggregates `URLRequest` + response headers, data and error _and_ gives you simple speed metering capability by recording start and end of each network call.

* `ServerTrustPolicy` is directly picked up from [Alamofire](https://github.com/Alamofire/Alamofire); it’s great as it is and there’s no need to reinvent the wheel.

`AsyncOperation` is my own [simple subclass](https://github.com/radianttap/Swift-Essentials/blob/master/Operation/AsyncOperation.swift) which makes sure that `Operation` is marked `finished` only when the network async callback returns. `Atomic.swift` is required by AsyncOperation.

## NetworkTask

I have extended URLSessionTask with additional properties.
Such [trickery is required](http://aplus.rs/2017/urlsession-in-operation/) to overcome URLSession/URLSessionTask API design, which is not compatible with `Operation`s. Read the [original post on my blog](http://aplus.rs/2017/thoughts-on-urlsession/) for more thoughts on this.

Apple [insists](http://developer.apple.com/videos/play/wwdc2017/709) that you should re-use `URLSession` instance across your app or at least have one per host.

Thus I needed to open some doors to re-route data received in the `URLSessionDelegate` (that’s `NetworkSession` in Avenue) into the `URLSessionDataTask` created internally inside the `NetworkOperation`. 

## Compatibility

I have used it and tested it extensively (on live projects) in **iOS 10+** and **watchOS 3.2+** and **tvOS 10+**. It probably works in earlier versions but I have not tried it. I suspect it will work just fine on macOS too but I have not tried that either.

The latest version is Swift 4.2 compatible.

## License

[MIT License,](https://github.com/radianttap/Avenue/blob/v2/LICENSE) like all my open source code.

## Credits

* **Alamofire** community for their invaluable work over the years. I don’t use the library itself, but there are re-usable gems in it (like ServerTrustPolicy handling).

* **Marcus Zarra** for this [great talk](https://academy.realm.io/posts/slug-marcus-zarra-exploring-mvcn-swift/) which got me started to write this library. There’s a [blog post](http://www.cimgf.com/2016/01/28/a-modern-network-operation/) on his blog too.

I want re-iterate what Marcus said at the end of his talk:

> Write it [network code] yourself. I guarantee code you write yourself will be faster than any generic code, that is the law. Whenever you write something that is very specific, it is going to be faster than generics.

## Learn more

* ATS ([Advanced Transport Security](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33))

* TN2232: [HTTPS Server Trust Evaluation](https://developer.apple.com/library/content/technotes/tn2232/)

### Helpful articles

* [Security analysis](https://www.nowsecure.com/blog/2017/08/31/security-analysts-guide-nsapptransportsecurity-nsallowsarbitraryloads-app-transport-security-ats-exceptions/) of ATS

* Alamofire [notes on ATS](https://github.com/Alamofire/Alamofire#app-transport-security)
* Resolving [ATS issues](https://github.com/Alamofire/Alamofire/issues/876)

* [Use SSL pinning](https://infinum.co/the-capsized-eight/how-to-make-your-ios-apps-more-secure-with-ssl-pinning)

### Tools

* [Bad SSL](https://badssl.com) in many ways, fantastic resource to test your code.

* `nscurl --help` (in your macOS Terminal)
