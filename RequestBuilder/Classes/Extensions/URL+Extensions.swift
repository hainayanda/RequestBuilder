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
    
    func httpRequest(_ method: HTTPRequestMethod) -> BareHTTPURLRequestBuilder {
        request().httpMethod(method)
    }
    
    func httpGet() -> BareHTTPURLRequestBuilder {
        httpRequest(.get)
    }
    
    func httpPost() -> BareHTTPURLRequestBuilder {
        httpRequest(.post)
    }
    
    func httpPut() -> BareHTTPURLRequestBuilder {
        httpRequest(.put)
    }
    
    func httpDelete() -> BareHTTPURLRequestBuilder {
        httpRequest(.delete)
    }
    
    func httpPatch() -> BareHTTPURLRequestBuilder {
        httpRequest(.patch)
    }
}
