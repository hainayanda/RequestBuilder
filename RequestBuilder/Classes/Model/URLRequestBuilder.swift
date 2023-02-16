//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 15/2/23.
//

import Foundation

// MARK: HTTPRequestMethod

public enum HTTPRequestMethod: String {
    case get
    case head
    case post
    case put
    case delete
    case connect
    case options
    case trace
    case patch
}

// MARK: BaseURLRequestBuilding Protocol

public protocol BaseURLRequestBuilding {
    var rawRequest: URLRequest { get }
    func addHeaders(value: String, forField field: String) -> Self
    func cachePolicy(_ policy: URLRequest.CachePolicy) -> Self
    func timeoutInterval(_ interval: TimeInterval) -> Self
    func networkServiceType(_ type: URLRequest.NetworkServiceType) -> Self
    func allowsCellularAccess(_ allowed: Bool) -> Self
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func allowsExpensiveNetworkAccess(_ allowed: Bool) -> Self
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func allowsConstrainedNetworkAccess(_ allowed: Bool) -> Self
    @available(macOS 13.0, iOS 16.1, watchOS 9.1, tvOS 16.1, *)
    func requiresDNSSECValidation(_ required: Bool) -> Self
}

public extension BaseURLRequestBuilding {
    func addHeaders(_ headers: [String: String]) -> Self {
        headers.reduce(self) { partialResult, pair in
            partialResult.addHeaders(value: pair.value, forField: pair.key)
        }
    }
    
    func contentType(_ type: HTTPContentType) -> Self {
        addHeaders(value: type.stringRepresentation, forField: "Content-Type")
    }
}

// MARK: URLRequestBuilding Protocol

public protocol URLRequestBuilding: BaseURLRequestBuilding {
    associatedtype HTTPBuilder: BareHTTPURLRequestBuilding
    
    func httpMethod(_ method: HTTPRequestMethod) -> HTTPBuilder
}

// MARK: BareHTTPURLRequestBuilding Protocol

public protocol BareHTTPURLRequestBuilding: HTTPURLRequestBuilding {
    associatedtype PayloadedBuilder: HTTPURLRequestBuilding
    
    func httpBody(_ data: Data) -> PayloadedBuilder
    func httpBody(_ stream: InputStream?) -> PayloadedBuilder
}

public extension BareHTTPURLRequestBuilding {
    func httpBody(_ plainText: String, encoding: String.Encoding = .utf8) throws -> PayloadedBuilder {
        guard let data = plainText.data(using: encoding) else {
            throw URLRequestBuilderError.stringEncodeFail(plainText, encoding)
        }
        return contentType(.text(.plain)).httpBody(data)
    }
    
    func httpJSONBody<Encoded: Encodable>(encoder: JSONEncoder = JSONEncoder(), _ encodable: Encoded) throws -> PayloadedBuilder {
        contentType(.application(.json)).httpBody(try encoder.encode(encodable))
    }
    
    func httpJSONBody(object: [String: Any]) throws -> PayloadedBuilder {
        contentType(.application(.json)).httpBody(try JSONSerialization.data(withJSONObject: object))
    }
    
    func httpJSONBody(array: [Any]) throws -> PayloadedBuilder {
        contentType(.application(.json)).httpBody(try JSONSerialization.data(withJSONObject: array))
    }
}

// MARK: HTTPURLRequestBuilding Protocol

public protocol HTTPURLRequestBuilding: BaseURLRequestBuilding {
    @available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *)
    func assumesHTTP3Capable(_ capable: Bool) -> Self
    func httpShouldHandleCookies(_ handleCookies: Bool) -> Self
    func httpShouldUsePipelining(_ usePipelining: Bool) -> Self
}

// MARK: BaseURLRequestBuilder

public class BaseURLRequestBuilder: BaseURLRequestBuilding {
    
    public let rawRequest: URLRequest
    
    required init(request: URLRequest) {
        self.rawRequest = request
    }
    
    func modified(_ modifying: (inout URLRequest) -> Void) -> Self {
        var mutableRequest = rawRequest
        modifying(&mutableRequest)
        return Self.init(request: mutableRequest)
    }
    
    public func addHeaders(value: String, forField field: String) -> Self {
        modified { $0.addValue(value, forHTTPHeaderField: field) }
    }
    
    public func cachePolicy(_ policy: URLRequest.CachePolicy) -> Self {
        modified {
            $0.cachePolicy = policy
        }
    }
    
    public func timeoutInterval(_ interval: TimeInterval) -> Self {
        modified { $0.timeoutInterval = interval }
    }
    
    public func networkServiceType(_ type: URLRequest.NetworkServiceType) -> Self {
        modified { $0.networkServiceType = type }
    }
    
    public func allowsCellularAccess(_ allowed: Bool) -> Self {
        modified { $0.allowsCellularAccess = allowed }
    }
    
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func allowsExpensiveNetworkAccess(_ allowed: Bool) -> Self {
        modified { $0.allowsExpensiveNetworkAccess = allowed }
    }
    
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func allowsConstrainedNetworkAccess(_ allowed: Bool) -> Self {
        modified { $0.allowsConstrainedNetworkAccess = allowed }
    }
    
    @available(macOS 13.0, iOS 16.1, watchOS 9.1, tvOS 16.1, *)
    public func requiresDNSSECValidation(_ required: Bool) -> Self {
        modified { $0.requiresDNSSECValidation = required }
    }
}

// MARK: URLRequestBuilder

public class URLRequestBuilder: BaseURLRequestBuilder, URLRequestBuilding {
    
    public typealias HTTPBuilder = BareHTTPURLRequestBuilder
    
    public func httpMethod(_ method: HTTPRequestMethod) -> BareHTTPURLRequestBuilder {
        HTTPBuilder(request: rawRequest).modified { $0.httpMethod = method.rawValue.uppercased() }
    }
}

// MARK: HTTPURLRequestBuilder

public class HTTPURLRequestBuilder: BaseURLRequestBuilder, HTTPURLRequestBuilding {
    
    @available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *)
    public func assumesHTTP3Capable(_ capable: Bool) -> Self {
        modified { $0.assumesHTTP3Capable = capable }
    }
    
    public func httpShouldHandleCookies(_ handleCookies: Bool) -> Self {
        modified { $0.httpShouldHandleCookies = handleCookies }
    }
    
    public func httpShouldUsePipelining(_ usePipelining: Bool) -> Self {
        modified { $0.httpShouldUsePipelining = usePipelining }
    }
}

// MARK: BareHTTPURLRequestBuilder

public class BareHTTPURLRequestBuilder: HTTPURLRequestBuilder, BareHTTPURLRequestBuilding {
    
    public typealias PayloadedBuilder = HTTPURLRequestBuilder
    
    public func httpBody(_ data: Data) -> HTTPURLRequestBuilder {
        PayloadedBuilder(request: rawRequest).modified { $0.httpBody = data }
    }
    
    public func httpBody(_ stream: InputStream?) -> HTTPURLRequestBuilder {
        PayloadedBuilder(request: rawRequest).modified { $0.httpBodyStream = stream }
    }
}
