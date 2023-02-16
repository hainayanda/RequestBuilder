//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 15/2/23.
//

import Foundation
import Combine

public extension BaseURLRequestBuilder {
    func dataTask(
        using session: URLSession = .shared,
        _ retryResponder: AsyncRequestRetryResponder<Data> = .default,
        _ stateResponder: AsyncRequestStateResponder<Data> = .default) -> AsyncRequest<Data> {
            DataAsyncURLRequest(
                request: rawRequest,
                session: session,
                retryResponder: retryResponder,
                stateResponder: stateResponder
            )
        }
}

// MARK: DataAsyncURLRequest

class DataAsyncURLRequest: AsyncRequest<Data> {
    
    private var observation: NSKeyValueObservation!
    private var dataTask: URLSessionDataTask!
    
    init(
        request: URLRequest,
        session: URLSession,
        retryResponder: AsyncRequestRetryResponder<Data>,
        stateResponder: AsyncRequestStateResponder<Data>) {
            super.init()
            self.sendRequest(request: request, session: session, retryResponder: retryResponder, stateResponder: stateResponder)
        }
    
    deinit { observation.invalidate() }
    
    override func cancel() {
        dataTask.cancel()
        super.cancel()
    }
    
    override func resume() {
        dataTask.resume()
        super.resume()
    }
    
    override func suspend() {
        dataTask.suspend()
        super.suspend()
    }
    
    private func sendRequest(request: URLRequest, session: URLSession, retryResponder: AsyncRequestRetryResponder<Data>, stateResponder: AsyncRequestStateResponder<Data>) {
        let dataTask = session.dataTask(with: request) { data, response, error in
            Task {
                let requestResponse = URLRequestResponse(payload: data, response: response, error: nil)
                let state = stateResponder.asyncRequest(self, stateFor: requestResponse)
                let shouldRetry = await retryResponder.asyncRequest(self, shouldRetryFor: state)
                guard shouldRetry else {
                    switch state {
                    case .success(let response):
                        self.state = .completed(response)
                    case .failing(let response):
                        self.state = .fail(response)
                    }
                    return
                }
                self.observation.invalidate()
                self.sendRequest(request: request, session: session, retryResponder: retryResponder, stateResponder: stateResponder)
            }
        }
        self.observation = dataTask.progress.observe(\.fractionCompleted) { [unowned self] progress, _ in
            self.progress = progress.fractionCompleted
        }
        self.dataTask = dataTask
        dataTask.resume()
    }
    
}
