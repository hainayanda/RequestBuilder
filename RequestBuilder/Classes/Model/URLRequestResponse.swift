//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 15/2/23.
//

import Foundation

public struct URLRequestResponse<Body: Equatable>: Equatable {
    public let payload: Body?
    public let response: URLResponse?
    public let error: Error?
    
    public static func == (lhs: URLRequestResponse, rhs: URLRequestResponse) -> Bool {
        lhs.payload == rhs.payload && lhs.response == rhs.response
    }
}

extension URLRequestResponse {
    
    public var isHTTPResponse: Bool {
        response as? HTTPURLResponse != nil
    }
    
    public var httpStatusCode: Int {
        (response as? HTTPURLResponse)?.statusCode ?? -1
    }
    
    public var hasError: Bool {
        error != nil
    }
}

extension URLRequestResponse where Body == Data {
    
    public func decodeJSONData<Decoded: Decodable>(decoder: JSONDecoder = JSONDecoder(), _ type: Decoded.Type = Decoded.self) throws -> Decoded {
        guard let payload else { throw URLRequestResponseError.noData }
        return try decoder.decode(type, from: payload)
    }
}

extension URLRequestResponse where Body == URL {
    
    public var dataDownloaded: Data {
        get throws {
            guard let payload else { throw URLRequestResponseError.noData }
            return try Data(contentsOf: payload)
        }
    }
}
