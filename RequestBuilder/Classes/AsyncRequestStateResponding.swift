//
//  Responder.swift
//  RequestBuilder
//
//  Created by Nayanda Haberty on 15/2/23.
//

import Foundation

// MARK: AsyncRequestStateResponding

public protocol AsyncRequestStateResponding: AnyObject {
    associatedtype Body: Equatable
    
    func asyncRequest(_ request: AsyncRequest<Body>, stateFor response: URLRequestResponse<Body>) -> AsyncRequestStateResponse<Body>
    @discardableResult
    func addNext(_ responder: AsyncRequestStateResponder<Body>) -> AsyncRequestStateResponder<Body>
}

// MARK: AsyncRequestStateResponder

public extension AsyncRequestStateResponder {
    static var `default`: AsyncRequestStateResponder<Body> { .init() }
}

public class AsyncRequestStateResponder<Body: Equatable>: AsyncRequestStateResponding {
    
    var nextResponder: AsyncRequestStateResponder<Body>?
    
    public func asyncRequest(_ request: AsyncRequest<Body>, stateFor response: URLRequestResponse<Body>) -> AsyncRequestStateResponse<Body> {
        askNextResponder(request, stateFor: response)
    }
    
    @discardableResult
    public func addNext(_ responder: AsyncRequestStateResponder<Body>) -> AsyncRequestStateResponder<Body> {
        guard let nextResponder else {
            self.nextResponder = responder
            return self
        }
        nextResponder.addNext(responder)
        return self
    }
    
    func askNextResponder(_ request: AsyncRequest<Body>, stateFor response: URLRequestResponse<Body>) -> AsyncRequestStateResponse<Body> {
        guard let nextResponder else {
            return response.hasError ? .failing(response): .success(response)
        }
        return nextResponder.asyncRequest(request, stateFor: response)
    }
}

// MARK: AsyncRequestStateResponder + StatusCodeStateResponder

public extension AsyncRequestStateResponder {
    static func allowed(statusCodes: Int...) -> AsyncRequestStateResponder<Body> {
        StatusCodeStateResponder(allowedStatusCode: statusCodes)
    }
    
    static func allowed(statusCodes: Range<Int>) -> AsyncRequestStateResponder<Body> {
        StatusCodeStateResponder(allowedStatusCode: Array(statusCodes))
    }
    
    func allowed(statusCodes: Int...) -> AsyncRequestStateResponder<Body> {
        addNext(StatusCodeStateResponder(allowedStatusCode: statusCodes))
    }
    
    func allowed(statusCodes: Range<Int>) -> AsyncRequestStateResponder<Body> {
        addNext(.allowed(statusCodes: statusCodes))
    }
}

// MARK: StatusCodeStateResponder

class StatusCodeStateResponder<Body: Equatable>: AsyncRequestStateResponder<Body> {
    
    private var allowedStatusCode: [Int]
    
    init(allowedStatusCode: [Int]) {
        self.allowedStatusCode = allowedStatusCode
    }
    
    override func asyncRequest(_ request: AsyncRequest<Body>, stateFor response: URLRequestResponse<Body>) -> AsyncRequestStateResponse<Body> {
        guard allowedStatusCode.contains(response.httpStatusCode) else {
            return .failing(response)
        }
        return askNextResponder(request, stateFor: response)
    }
}

// MARK: AsyncRequestStateResponder + ClosureStateResponder

public extension AsyncRequestStateResponder {
    static func failIf(conditionMet: @escaping (URLRequestResponse<Body>) -> Bool) -> AsyncRequestStateResponder<Body> {
        ClosureStateResponder { _, response in
            guard conditionMet(response) else {
                return .success(response)
            }
            return .failing(response)
        }
    }
    
    func failIf(conditionMet: @escaping (URLRequestResponse<Body>) -> Bool) -> AsyncRequestStateResponder<Body> {
        addNext(.failIf(conditionMet: conditionMet))
    }
    
    static func allowedIf(conditionMet: @escaping (URLRequestResponse<Body>) -> Bool) -> AsyncRequestStateResponder<Body> {
        ClosureStateResponder { _, response in
            guard conditionMet(response) else {
                return .failing(response)
            }
            return .success(response)
        }
    }
    
    func allowedIf(conditionMet: @escaping (URLRequestResponse<Body>) -> Bool) -> AsyncRequestStateResponder<Body> {
        addNext(.allowedIf(conditionMet: conditionMet))
    }
}

// MARK: ClosureStateResponder

public class ClosureStateResponder<Body: Equatable>: AsyncRequestStateResponder<Body> {
    
    let closure: (AsyncRequest<Body>, URLRequestResponse<Body>) -> AsyncRequestStateResponse<Body>
    
    public init(closure: @escaping (AsyncRequest<Body>, URLRequestResponse<Body>) -> AsyncRequestStateResponse<Body>) {
        self.closure = closure
    }
    
    override public func asyncRequest(_ request: AsyncRequest<Body>, stateFor response: URLRequestResponse<Body>) -> AsyncRequestStateResponse<Body> {
        switch closure(request, response) {
        case .success:
            return askNextResponder(request, stateFor: response)
        case .failing:
            return .failing(response)
        }
    }
}
