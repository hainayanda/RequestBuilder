//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 15/2/23.
//

import Foundation
import Combine

open class AsyncRequest<Body: Equatable> {
    
    @Published public internal(set) var state: RequestState<Body> = .onProgress
    @Published public internal(set) var progress: Double = 0
    
    public var response: URLRequestResponse<Body> {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                var cancelable: AnyCancellable?
                cancelable = self.$state.sink { state in
                    switch state {
                    case .completed(let response), .fail(let response):
                        continuation.resume(returning: response)
                    case .suspended:
                        continuation.resume(throwing: AsyncRequestError.requestSuspended)
                    case .cancelled:
                        continuation.resume(throwing: AsyncRequestError.requestCancelled)
                    default:
                        return
                    }
                    cancelable?.cancel()
                }
            }
        }
    }
    
    open func cancel() {
        state = .cancelled
    }
    
    open func resume() {
        state = .onProgress
    }
    
    open func suspend() {
        state = .suspended
    }
}

open class ResumableAsyncRequest<Body: Equatable, ResumeData>: AsyncRequest<Body> {
    
    open func cancel() async -> Data? { return nil }
}
