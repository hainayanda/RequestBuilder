//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 15/2/23.
//

import Foundation

public extension URL {
    func request() -> URLRequestBuilder {
        .init(request: URLRequest(url: self))
    }
    
    func httpRequest(_ method: HTTPRequestMethod) -> HTTPURLRequestBuilder {
        request().httpMethod(method)
    }
    
    func httpGet() -> HTTPURLRequestBuilder {
        httpRequest(.get)
    }
    
    func httpPost() -> HTTPURLRequestBuilder {
        httpRequest(.post)
    }
    
    func httpPut() -> HTTPURLRequestBuilder {
        httpRequest(.put)
    }
    
    func httpDelete() -> HTTPURLRequestBuilder {
        httpRequest(.delete)
    }
    
    func httpPatch() -> HTTPURLRequestBuilder {
        httpRequest(.patch)
    }
}
