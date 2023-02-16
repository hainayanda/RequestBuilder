//
//  AsyncRequestRetryResponding.swift
//  RequestBuilder
//
//  Created by Nayanda Haberty on 16/2/23.
//

import Foundation

// MARK: AsyncRequestStateResponse

public enum AsyncRequestStateResponse<Body: Equatable>: Equatable {
    case success(URLRequestResponse<Body>)
    case failing(URLRequestResponse<Body>)
}

// MARK: AsyncRequestRetryResponder

public protocol AsyncRequestRetryResponding: AnyObject {
    associatedtype Body: Equatable
    
    func asyncRequest(_ request: AsyncRequest<Body>, shouldRetryFor state: AsyncRequestStateResponse<Body>) async -> Bool
    @discardableResult
    func addNext(_ responder: AsyncRequestRetryResponder<Body>) -> AsyncRequestRetryResponder<Body>
}

// MARK: AsyncRequestRetryResponder

public extension AsyncRequestRetryResponder {
    static var `default`: AsyncRequestRetryResponder<Body> { .init() }
}

public class AsyncRequestRetryResponder<Body: Equatable>: AsyncRequestRetryResponding {
    
    var nextResponder: AsyncRequestRetryResponder<Body>?
    
    public func asyncRequest(_ request: AsyncRequest<Body>, shouldRetryFor state: AsyncRequestStateResponse<Body>) async -> Bool {
        await askNextResponder(request, shouldRetryFor: state)
    }
    
    @discardableResult
    public func addNext(_ responder: AsyncRequestRetryResponder<Body>) -> AsyncRequestRetryResponder<Body> {
        guard let nextResponder else {
            self.nextResponder = responder
            return self
        }
        nextResponder.addNext(responder)
        return self
    }
    
    func askNextResponder(_ request: AsyncRequest<Body>, shouldRetryFor state: AsyncRequestStateResponse<Body>) async -> Bool {
        guard let nextResponder else {
            return false
        }
        return await nextResponder.asyncRequest(request, shouldRetryFor: state)
    }
}

// MARK: AsyncRequestRetryResponder + RetryCounterResponder

public extension AsyncRequestRetryResponder {
    static func retryIfFail(max: Int) -> AsyncRequestRetryResponder<Body> {
        RetryCounterResponder(maxRetryCount: max)
    }
    
    func retryIfFail(max: Int) -> AsyncRequestRetryResponder<Body> {
        addNext(RetryCounterResponder(maxRetryCount: max))
    }
}

// MARK: RetryCounterResponder

class RetryCounterResponder<Body: Equatable>: AsyncRequestRetryResponder<Body> {
    
    private let maxRetryCount: Int
    private var retryCounter: Int = 0
    
    init(maxRetryCount: Int) {
        self.maxRetryCount = maxRetryCount
    }
    
    override func asyncRequest(_ request: AsyncRequest<Body>, shouldRetryFor state: AsyncRequestStateResponse<Body>) async -> Bool {
        guard retryCounter < maxRetryCount else {
            return false
        }
        switch state {
        case .failing:
            retryCounter += 1
            return true
        case .success:
            return await askNextResponder(request, shouldRetryFor: state)
        }
    }
    
    override func askNextResponder(_ request: AsyncRequest<Body>, shouldRetryFor state: AsyncRequestStateResponse<Body>) async -> Bool {
        guard await super.askNextResponder(request, shouldRetryFor: state) else {
            return false
        }
        retryCounter += 1
        return true
    }
}

// MARK: AsyncRequestRetryResponder + ClosureRetryResponder

public extension AsyncRequestRetryResponder {
    static func retryIf(conditionMet: @escaping (AsyncRequestStateResponse<Body>) -> Bool) -> AsyncRequestRetryResponder<Body> {
        ClosureRetryResponder { _, state in
            guard conditionMet(state) else {
                return false
            }
            return true
        }
    }
    
    func retryIf(conditionMet: @escaping (AsyncRequestStateResponse<Body>) -> Bool) -> AsyncRequestRetryResponder<Body> {
        addNext(.retryIf(conditionMet: conditionMet))
    }
    
    static func doNotRetryIf(conditionMet: @escaping (AsyncRequestStateResponse<Body>) -> Bool) -> AsyncRequestRetryResponder<Body> {
        ClosureRetryResponder { _, state in
            guard conditionMet(state) else {
                return true
            }
            return false
        }
    }
    
    func doNotRetryIf(conditionMet: @escaping (AsyncRequestStateResponse<Body>) -> Bool) -> AsyncRequestRetryResponder<Body> {
        addNext(.doNotRetryIf(conditionMet: conditionMet))
    }
}

// MARK: ClosureRetryResponder

public class ClosureRetryResponder<Body: Equatable>: AsyncRequestRetryResponder<Body> {
    
    private let closure: (AsyncRequest<Body>, AsyncRequestStateResponse<Body>) -> Bool
    
    public init(closure: @escaping (AsyncRequest<Body>, AsyncRequestStateResponse<Body>) -> Bool) {
        self.closure = closure
    }
    
    override public func asyncRequest(_ request: AsyncRequest<Body>, shouldRetryFor state: AsyncRequestStateResponse<Body>) async -> Bool {
        guard closure(request, state) else {
            return await askNextResponder(request, shouldRetryFor: state)
        }
        return true
    }
}
